# Skill Invocation Test Report

**Date:** 2026-03-28_17-02-43
**Model:** sonnet
**Runs per sample:** 100
**Skills tested:** echo discuss fluent

## Overall Results

| Sample | Pass | Fail | Error | Pass Rate |
|---|---|---|---|---|
| No hook | 69 | 31 | 0 | 69% |
| With hook | 82 | 18 | 0 | 82% |

## Per-Skill Breakdown

| Skill | No hook | With hook |
|---|---|---|
| echo | 18/28 (64%) | 25/29 (86%) |
| discuss | 26/35 (74%) | 30/36 (83%) |
| fluent | 25/37 (67%) | 27/35 (77%) |

## Per-Position Breakdown

| Position | No hook | With hook |
|---|---|---|
| start | 0/30 (0%) | 12/26 (46%) |
| middle | 42/43 (97%) | 33/36 (91%) |
| end | 27/27 (100%) | 37/38 (97%) |

## Statistical Significance

**Question:** Does the UserPromptSubmit hook improve skill invocation reliability?

| Group | Role | Pass Rate | Runs |
|---|---|---|---|
| No hook (control) | Baseline — Claude invokes skills without the hook | 69% (69/100) | 100 |
| With hook (experiment) | Hook rewrites  to  before Claude sees the prompt | 82% (82/100) | 100 |

Chi-squared test (is the difference in pass rates due to chance?):

| Metric | Value |
|---|---|
| Chi-squared | 3.8924 |
| p-value | 0.048505 |

**Result: Significant (p < 0.05).** The hook likely improves skill invocation. The difference is unlikely to be due to chance.

---
*Raw data: [2026-03-28_17-02-43_skill_test_report.jsonl](2026-03-28_17-02-43_skill_test_report.jsonl)*
