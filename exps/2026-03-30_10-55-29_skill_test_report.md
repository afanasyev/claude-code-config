# Skill Invocation Test Report

**Date:** 2026-03-30_10-55-29
**Model:** sonnet
**Runs:** 99 (paired, same shuffled order for both samples)
**Skills tested:** discuss echo fluent

## Overall Results

| Sample | Pass | Fail | Error | Pass Rate |
|---|---|---|---|---|
| A: No hook | 90 | 9 | 0 | 90% |
| B: With hook | 99 | 0 | 0 | 100% |

## Per-Skill Breakdown

| Skill | Sample A (no hook) | Sample B (with hook) |
|---|---|---|
| discuss | 33/33 (100%) | 33/33 (100%) |
| echo | 27/33 (81%) | 33/33 (100%) |
| fluent | 30/33 (90%) | 33/33 (100%) |

## Per-Position Breakdown

| Position | Sample A (no hook) | Sample B (with hook) |
|---|---|---|
| start | 11/11 (100%) | 11/11 (100%) |
| middle | 11/11 (100%) | 11/11 (100%) |
| end | 68/77 (88%) | 77/77 (100%) |

## Statistical Significance (McNemar's Test)

**Question:** Does the UserPromptSubmit hook improve skill invocation reliability?

| Group | Condition | Pass Rate | Runs |
|---|---|---|---|
| Sample A | No hook (baseline) | 91% (90/99) | 99 |
| Sample B | With hook | 100% (99/99) | 99 |

**Paired analysis (discordant pairs):**

| Pair type | Count |
|---|---|
| A=fail, B=pass (hook helped) | 9 |
| A=pass, B=fail (hook hurt) | 0 |
| Concordant (both same) | 90 |

| Metric | Value |
|---|---|
| McNemar statistic (with continuity correction) | 7.1111 |
| p-value | 0.007661 |

**Result: Significant (p < 0.05).** The hook likely improves skill invocation.

---
*Raw data: [2026-03-30_10-55-29_skill_test_report.jsonl](2026-03-30_10-55-29_skill_test_report.jsonl)*
