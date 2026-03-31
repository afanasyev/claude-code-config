#!/bin/bash
# Test skill invocation reliability
# Usage: cd ~/.claude && bash exps/test_skills.sh

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
SETTINGS_BACKUP="$CLAUDE_DIR/settings.json.test-bak"
TESTS_DIR="$CLAUDE_DIR/exps"
PROMPTS_FILE="$TESTS_DIR/test_prompts.json"
MODEL="sonnet"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$CLAUDE_DIR/projects/-Users-afanasyev--claude"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
JSONL_FILE="$TESTS_DIR/${TIMESTAMP}_skill_test_report.jsonl"
MD_FILE="$TESTS_DIR/${TIMESTAMP}_skill_test_report.md"
SHUFFLED_FILE=$(mktemp)

mkdir -p "$PROJECT_DIR"

# --- Startup guard ---
if ! python3 -c "
import json, sys
with open('$SETTINGS') as f:
    s = json.load(f)
hooks = s.get('hooks', {})
if 'UserPromptSubmit' not in hooks:
    print('ERROR: UserPromptSubmit hook is missing from settings.json')
    print('The hook is required for sample B (with hook).')
    print('Add it back before running this test.')
    sys.exit(1)
" 2>&1; then
  exit 1
fi

# --- Load and shuffle prompts ---
TOTAL=$(python3 -c "import json; print(len(json.load(open('$PROMPTS_FILE'))))")
RUNS=${1:-$TOTAL}

python3 -c "
import json, random
with open('$PROMPTS_FILE') as f:
    prompts = json.load(f)
random.shuffle(prompts)
for p in prompts:
    print(p['skill'] + '\t' + p['position'] + '\t' + p['prompt'])
" > "$SHUFFLED_FILE"

mapfile -t SKILL_LIST < <(cut -f1 "$SHUFFLED_FILE")
mapfile -t POSITION_LIST < <(cut -f2 "$SHUFFLED_FILE")
mapfile -t PROMPT_LIST < <(cut -f3 "$SHUFFLED_FILE")

# --- Cleanup trap ---
cleanup() {
  restore_hook
  rm -f "$SHUFFLED_FILE"
  echo ""
  echo "Cleanup done."
}
trap cleanup EXIT

list_sessions() {
  ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null || true
}

check_skill_invoked() {
  local session_file="$1"
  if [ -z "$session_file" ] || [ ! -f "$session_file" ]; then
    echo "no_session"
    return
  fi
  if grep -q '"name":"Skill"' "$session_file" 2>/dev/null || grep -q '"name": "Skill"' "$session_file" 2>/dev/null; then
    echo "pass"
  else
    echo "fail"
  fi
}

find_new_session() {
  local before_files="$1"
  local after_files
  after_files=$(list_sessions)
  local new_file=""
  while IFS= read -r f; do
    if ! echo "$before_files" | grep -qF "$f"; then
      new_file="$f"
      break
    fi
  done <<< "$after_files"
  echo "$new_file"
}

remove_hook() {
  cp "$SETTINGS" "$SETTINGS_BACKUP"
  python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
hooks = s.get('hooks', {})
hooks.pop('UserPromptSubmit', None)
s['hooks'] = hooks
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
"
}

restore_hook() {
  if [ -f "$SETTINGS_BACKUP" ]; then
    cp "$SETTINGS_BACKUP" "$SETTINGS"
    rm -f "$SETTINGS_BACKUP"
  fi
}

run_test() {
  local prompt="$1"
  local before_files
  before_files=$(list_sessions)
  claude -p --model "$MODEL" "$prompt" > /dev/null 2>&1 || true
  sleep 2
  local new_session
  new_session=$(find_new_session "$before_files")
  if [ -z "$new_session" ]; then
    echo "error"
    return
  fi
  check_skill_invoked "$new_session"
}

log_jsonl() {
  local pair_id="$1" sample="$2" skill="$3" position="$4" prompt="$5" result="$6"
  printf '{"pair_id":%d,"sample":"%s","skill":"%s","position":"%s","prompt":"%s","result":"%s"}\n' \
    "$pair_id" "$sample" "$skill" "$position" "$prompt" "$result" >> "$JSONL_FILE"
}

# Track per-skill and per-position results
declare -A skill_pass_a skill_total_a skill_pass_b skill_total_b
declare -A pos_pass_a pos_total_a pos_pass_b pos_total_b
for s in discuss echo fluent; do
  skill_pass_a[$s]=0; skill_total_a[$s]=0
  skill_pass_b[$s]=0; skill_total_b[$s]=0
done
for p in start middle end; do
  pos_pass_a[$p]=0; pos_total_a[$p]=0
  pos_pass_b[$p]=0; pos_total_b[$p]=0
done

echo "========================================"
echo "  Skill Invocation Test Suite"
echo "  Model: $MODEL | Runs: $RUNS (paired)"
echo "  Prompts: $PROMPTS_FILE"
echo "  JSONL: $JSONL_FILE"
echo "  Report: $MD_FILE"
echo "========================================"
echo ""

# --- Sample A: No hook ---
echo -e "${YELLOW}Sample A: No hook ($RUNS runs, in shuffled order)${NC}"
remove_hook

pass_a=0; fail_a=0; error_a=0
for i in $(seq 0 $((RUNS - 1))); do
  pair_id=$((i + 1))
  skill="${SKILL_LIST[$i]}"
  pos="${POSITION_LIST[$i]}"
  prompt="${PROMPT_LIST[$i]}"
  result=$(run_test "$prompt")
  log_jsonl "$pair_id" "sample_a" "$skill" "$pos" "$prompt" "$result"
  case $result in
    pass)
      pass_a=$((pass_a + 1))
      skill_pass_a[$skill]=$((${skill_pass_a[$skill]} + 1))
      pos_pass_a[$pos]=$((${pos_pass_a[$pos]} + 1))
      ;;
    fail) fail_a=$((fail_a + 1)) ;;
    *)    error_a=$((error_a + 1)) ;;
  esac
  skill_total_a[$skill]=$((${skill_total_a[$skill]} + 1))
  pos_total_a[$pos]=$((${pos_total_a[$pos]} + 1))
  printf "  [%3d/$RUNS] %-8s %-6s %-5s | %s\n" "$pair_id" "$skill" "$pos" "$result" "$prompt"
done

restore_hook
echo ""
echo -e "Sample A: ${GREEN}$pass_a pass${NC} / ${RED}$fail_a fail${NC} / ${YELLOW}$error_a error${NC} out of $RUNS"
echo ""

# --- Sample B: With hook ---
echo -e "${YELLOW}Sample B: With hook ($RUNS runs, same shuffled order)${NC}"

pass_b=0; fail_b=0; error_b=0
for i in $(seq 0 $((RUNS - 1))); do
  pair_id=$((i + 1))
  skill="${SKILL_LIST[$i]}"
  pos="${POSITION_LIST[$i]}"
  prompt="${PROMPT_LIST[$i]}"
  result=$(run_test "$prompt")
  log_jsonl "$pair_id" "sample_b" "$skill" "$pos" "$prompt" "$result"
  case $result in
    pass)
      pass_b=$((pass_b + 1))
      skill_pass_b[$skill]=$((${skill_pass_b[$skill]} + 1))
      pos_pass_b[$pos]=$((${pos_pass_b[$pos]} + 1))
      ;;
    fail) fail_b=$((fail_b + 1)) ;;
    *)    error_b=$((error_b + 1)) ;;
  esac
  skill_total_b[$skill]=$((${skill_total_b[$skill]} + 1))
  pos_total_b[$pos]=$((${pos_total_b[$pos]} + 1))
  printf "  [%3d/$RUNS] %-8s %-6s %-5s | %s\n" "$pair_id" "$skill" "$pos" "$result" "$prompt"
done

echo ""
echo -e "Sample B: ${GREEN}$pass_b pass${NC} / ${RED}$fail_b fail${NC} / ${YELLOW}$error_b error${NC} out of $RUNS"
echo ""

# --- Console summary ---
valid_a=$((pass_a + fail_a))
valid_b=$((pass_b + fail_b))

echo "========================================"
echo "  RESULTS SUMMARY"
echo "========================================"
echo ""
printf "%-12s | %-20s | %-20s\n" "Skill" "Sample A (no hook)" "Sample B (with hook)"
printf "%-12s-+-%-20s-+-%-20s\n" "------------" "--------------------" "--------------------"
for skill in discuss echo fluent; do
  t_a=${skill_total_a[$skill]}; p_a=${skill_pass_a[$skill]}
  t_b=${skill_total_b[$skill]}; p_b=${skill_pass_b[$skill]}
  if [ "$t_a" -gt 0 ]; then pct_a=$((p_a * 100 / t_a)); else pct_a=0; fi
  if [ "$t_b" -gt 0 ]; then pct_b=$((p_b * 100 / t_b)); else pct_b=0; fi
  printf "%-12s | %3d/%3d (%3d%%)       | %3d/%3d (%3d%%)\n" "$skill" "$p_a" "$t_a" "$pct_a" "$p_b" "$t_b" "$pct_b"
done
echo ""
if [ "$valid_a" -gt 0 ]; then pct_total_a=$((pass_a * 100 / valid_a)); else pct_total_a=0; fi
if [ "$valid_b" -gt 0 ]; then pct_total_b=$((pass_b * 100 / valid_b)); else pct_total_b=0; fi
echo -e "TOTAL        | ${GREEN}$pass_a${NC}/${valid_a} (${pct_total_a}%) +${error_a} err  | ${GREEN}$pass_b${NC}/${valid_b} (${pct_total_b}%) +${error_b} err"
echo ""

# --- Generate Markdown report ---
cat > "$MD_FILE" << MDEOF
# Skill Invocation Test Report

**Date:** $TIMESTAMP
**Model:** $MODEL
**Runs:** $RUNS (paired, same shuffled order for both samples)
**Skills tested:** discuss echo fluent

## Overall Results

| Sample | Pass | Fail | Error | Pass Rate |
|---|---|---|---|---|
| A: No hook | $pass_a | $fail_a | $error_a | ${pct_total_a}% |
| B: With hook | $pass_b | $fail_b | $error_b | ${pct_total_b}% |

## Per-Skill Breakdown

| Skill | Sample A (no hook) | Sample B (with hook) |
|---|---|---|
MDEOF

for skill in discuss echo fluent; do
  t_a=${skill_total_a[$skill]}; p_a=${skill_pass_a[$skill]}
  t_b=${skill_total_b[$skill]}; p_b=${skill_pass_b[$skill]}
  if [ "$t_a" -gt 0 ]; then pct_a=$((p_a * 100 / t_a)); else pct_a=0; fi
  if [ "$t_b" -gt 0 ]; then pct_b=$((p_b * 100 / t_b)); else pct_b=0; fi
  echo "| $skill | $p_a/$t_a (${pct_a}%) | $p_b/$t_b (${pct_b}%) |" >> "$MD_FILE"
done

cat >> "$MD_FILE" << MDEOF

## Per-Position Breakdown

| Position | Sample A (no hook) | Sample B (with hook) |
|---|---|---|
MDEOF

for pos in start middle end; do
  t_a=${pos_total_a[$pos]}; p_a=${pos_pass_a[$pos]}
  t_b=${pos_total_b[$pos]}; p_b=${pos_pass_b[$pos]}
  if [ "$t_a" -gt 0 ]; then pct_a=$((p_a * 100 / t_a)); else pct_a=0; fi
  if [ "$t_b" -gt 0 ]; then pct_b=$((p_b * 100 / t_b)); else pct_b=0; fi
  echo "| $pos | $p_a/$t_a (${pct_a}%) | $p_b/$t_b (${pct_b}%) |" >> "$MD_FILE"
done

# --- McNemar's test ---
STATS=$("$CLAUDE_DIR/.venv/bin/python3" << PYEOF
import json
from scipy.stats import chi2

with open('$JSONL_FILE') as f:
    records = [json.loads(line) for line in f]

a_results = {r['pair_id']: r['result'] for r in records if r['sample'] == 'sample_a'}
b_results = {r['pair_id']: r['result'] for r in records if r['sample'] == 'sample_b'}

pairs = [(a_results[i], b_results[i]) for i in a_results if i in b_results]

pass_a = sum(1 for a, b in pairs if a == 'pass')
pass_b = sum(1 for a, b in pairs if b == 'pass')
n = len(pairs)
rate_a = pass_a / n * 100 if n > 0 else 0
rate_b = pass_b / n * 100 if n > 0 else 0

# Discordant pairs
b_count = sum(1 for a, b in pairs if a == 'fail' and b == 'pass')
c_count = sum(1 for a, b in pairs if a == 'pass' and b == 'fail')
discordant = b_count + c_count

print(f"## Statistical Significance (McNemar's Test)")
print(f"")
print(f"**Question:** Does the UserPromptSubmit hook improve skill invocation reliability?")
print(f"")
print(f"| Group | Condition | Pass Rate | Runs |")
print(f"|---|---|---|---|")
print(f"| Sample A | No hook (baseline) | {rate_a:.0f}% ({pass_a}/{n}) | {n} |")
print(f"| Sample B | With hook | {rate_b:.0f}% ({pass_b}/{n}) | {n} |")
print(f"")
print(f"**Paired analysis (discordant pairs):**")
print(f"")
print(f"| Pair type | Count |")
print(f"|---|---|")
print(f"| A=fail, B=pass (hook helped) | {b_count} |")
print(f"| A=pass, B=fail (hook hurt) | {c_count} |")
print(f"| Concordant (both same) | {n - discordant} |")
print(f"")

if discordant == 0:
    print(f"**Result: No discordant pairs — samples are identical. No difference detected.**")
else:
    # McNemar with continuity correction
    stat = (abs(b_count - c_count) - 1) ** 2 / discordant
    p = 1 - chi2.cdf(stat, df=1)
    print(f"| Metric | Value |")
    print(f"|---|---|")
    print(f"| McNemar statistic (with continuity correction) | {stat:.4f} |")
    print(f"| p-value | {p:.6f} |")
    print(f"")
    if p < 0.001:
        print(f"**Result: Highly significant (p < 0.001).** The hook reliably improves skill invocation.")
    elif p < 0.05:
        print(f"**Result: Significant (p < 0.05).** The hook likely improves skill invocation.")
    else:
        print(f"**Result: Not significant (p = {p:.4f}).** No reliable difference detected.")
PYEOF
)

echo "" >> "$MD_FILE"
echo "$STATS" >> "$MD_FILE"
echo "" >> "$MD_FILE"
echo "---" >> "$MD_FILE"
echo "*Raw data: [${TIMESTAMP}_skill_test_report.jsonl](${TIMESTAMP}_skill_test_report.jsonl)*" >> "$MD_FILE"

echo ""
echo "$STATS"
echo ""
echo "Report saved: $MD_FILE"
echo "Raw data: $JSONL_FILE"
