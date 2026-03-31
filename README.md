# ~/.claude

Global [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration — skills, commands, and hooks for consistent AI-assisted workflows.

## Skill invocation

Skills don't invoke reliably when mentioned inline — the model has to infer intent, and sometimes it doesn't. A `UserPromptSubmit` hook fixes this: it detects skill tags in your message and injects an explicit instruction to invoke the matched skill every time.

Use `#skill` or `/skill` in your message. `#` feels more natural inline — `Refactor this module #plan` reads like a hashtag, not a command.

## Skills

| Tag | Behavior |
|---|---|
| `#echo` | Restates understanding of the task. No questions, no analysis. Waits for confirmation. |
| `#plan` | Asks clarifying questions, writes a plan listing each file and change. No code until approved. |
| `#prd` | Breaks the task into vertical slices — each iteration is end-to-end, testable, and deployable. No code. |
| `#discuss` | Analysis and discussion only. No code. Questions, corner cases, options. |
| `#dig` | Searches from multiple angles. Collects findings. Returns a structured answer. No code. |
| `#fluent` | Rewrites text as a native English speaker. |
| `#whys` | 5-Whys root cause analysis. |
| `#team` | Modifier — invokes agent teams to solve the task in parallel. Combines with any skill. |

Skills are composable. Order doesn't matter.

| Combo | Behavior |
|---|---|
| `#plan #team` | Agents research different parts of the codebase in parallel, then propose one unified plan. |
| `#discuss #team` | Agents explore different aspects in parallel, then synthesize. |
| `#dig #team` | Agents research from different angles in parallel, then synthesize into one structured answer. |

## Commands

Invoked by typing the command name in Claude Code chat (e.g., `/commit`).

| Command | Description |
|---|---|
| `/commit` | Stages specific files (never `git add -A`), drafts a conventional commit message (`type(scope): description`). |
| `/pr-create` | Pushes branch, creates PR with summary and test plan via `gh pr create`. |

## Hooks

Shell scripts that run automatically at specific points in Claude's tool execution lifecycle.

| Hook | Trigger | What it does |
|---|---|---|
| `invoke_skill.sh` | On every user message | Detects `#skill` or `/skill` tags. Injects an explicit instruction to invoke the matched skill(s). Requires `jq`. |
| `ruff_check.sh` | After file write/edit | Runs `ruff check --fix` and `ruff format` on edited Python files. |
| `read_hook.js` | Before file read | Blocks reading `.env` files. |
