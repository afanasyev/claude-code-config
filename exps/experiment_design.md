# Experiment Design: Skill Invocation Reliability

## Problem

I have recurring interaction patterns with Claude that I use daily (discuss, echo, fluent).
I want to automate them so they trigger reliably with minimal effort using skill tags.

Current approach: skills + UserPromptSubmit hook.
The experiment measures how well this approach actually works.

---

## Hypotheses

**H1 — Baseline:** Skills invoke reliably without any action needed (no hook).

**H2 — Hook improves reliability:** The UserPromptSubmit hook increases skill invocation rate.

---

## Experiment: A/B Test

**Prompt pool:** `real_prompts.json` — 99 real prompts, 33 per skill, based on actual usage.

**Skills:** echo, discuss, fluent

**Runs:** 100 per sample, randomly sampled from the pool

**Pass condition:** Skill tool was invoked in the session

**Model:** sonnet

| Sample | Condition |
|---|---|
| A | No hook |
| B | With hook |

**Breakdown:** per skill (echo / discuss / fluent), per position (start / middle / end)

---

## Success Criteria

| Result | Interpretation |
|---|---|
| A ≥ 95% | H1 confirmed — hook not needed |
| A < 95%, B ≥ 95% | H2 confirmed — hook is sufficient |
| B < 95% | Neither sufficient — need further investigation |

---

## Output

- JSONL log per run (prompt, skill, position, result)
- Markdown report (pass rates by skill, position, statistical significance)
