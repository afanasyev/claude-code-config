#!/bin/bash
# PostToolUse hook: run ruff on edited Python files
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$file_path" == *.py ]]; then
  if command -v ruff &>/dev/null; then
    ruff check --fix "$file_path" 2>&1 || true
    ruff format "$file_path" 2>&1 || true
  else
    echo "ruff not installed, skipping lint" >&2
  fi
fi
