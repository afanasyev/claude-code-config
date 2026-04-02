**Commit Message Format:**

<type>(<scope>): <description>

- First change made
- Second change made
- Third change made

**Rules:**

1. Type (required):
    - feat: new feature or functionality
    - fix: bug fix or correction
    - refactor: code restructuring without behavior change
    - style: UI/styling changes
    - docs: documentation updates
    - chore: maintenance tasks
2. Scope (optional but preferred):
    - Component/module name: request, request-page, web, search, query-parser, templates, ui
    - Omit only for broad changes
3. Description (subject line):
    - Start with lowercase
    - Use imperative mood (add, update, remove, implement, fix)
    - Be specific and concise
    - No period at the end
    - Focus on WHAT changed at high level
4. Body (for non-trivial commits):
    - Leave one blank line after subject
    - Use bullet points (-) for each change
    - List specific modifications made
    - Be detailed and technical
    - Use imperative mood
    - Explain implementation details

**Examples:**

feat(request-page): add collapsible card details with product info in header

- Move product details (steel, profile, dimensions, quantity) to card header
- Add toggle button to expand/collapse characteristics and comments
- Set default state to collapsed for cleaner interface
- Always show characteristics and comments sections with em dash for empty values

fix(request-page): preserve newlines in user query display
(Simple fixes may not need a body)

**Task**

Commit the changes with the appropriate commit message following the above format and rules.

**IMPORTANT**

- Don't add Claude in commit messages.
- Avoid mentioning Claude in commit messages.
- Don't use command "git add -A", use "git add <file>" instead.
- Do NOT push to the remote repository. Commit only.
