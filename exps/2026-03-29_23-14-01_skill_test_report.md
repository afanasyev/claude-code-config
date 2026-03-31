# Skill Invocation Test Report

**Date:** 2026-03-29_23-14-01
**Model:** sonnet
**Runs:** 99 (paired, same shuffled order for both samples)
**Skills tested:** discuss echo fluent

## Overall Results

| Sample | Pass | Fail | Error | Pass Rate |
|---|---|---|---|---|
| A: No hook | 74 | 25 | 0 | 74% |
| B: With hook | 93 | 6 | 0 | 93% |

## Per-Skill Breakdown

| Skill | Sample A (no hook) | Sample B (with hook) |
|---|---|---|
| discuss | 22/33 (66%) | 27/33 (81%) |
| echo | 24/33 (72%) | 33/33 (100%) |
| fluent | 28/33 (84%) | 33/33 (100%) |

## Per-Position Breakdown

| Position | Sample A (no hook) | Sample B (with hook) |
|---|---|---|
| start | 0/11 (0%) | 5/11 (45%) |
| middle | 11/11 (100%) | 11/11 (100%) |
| end | 63/77 (81%) | 77/77 (100%) |

## Statistical Significance (McNemar's Test)

**Question:** Does the UserPromptSubmit hook improve skill invocation reliability?

| Group | Condition | Pass Rate | Runs |
|---|---|---|---|
| Sample A | No hook (baseline) | 75% (74/99) | 99 |
| Sample B | With hook | 94% (93/99) | 99 |

**Paired analysis (discordant pairs):**

| Pair type | Count |
|---|---|
| A=fail, B=pass (hook helped) | 19 |
| A=pass, B=fail (hook hurt) | 0 |
| Concordant (both same) | 80 |

| Metric | Value |
|---|---|
| McNemar statistic (with continuity correction) | 17.0526 |
| p-value | 0.000036 |

**Result: Highly significant (p < 0.001).** The hook reliably improves skill invocation.

---
*Raw data: [2026-03-29_23-14-01_skill_test_report.jsonl](2026-03-29_23-14-01_skill_test_report.jsonl)*
