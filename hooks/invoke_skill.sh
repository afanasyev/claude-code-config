#!/bin/bash
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt')

skills=""
[[ "$prompt" == *"#echo"* ]] || [[ "$prompt" == *"/echo"* ]] && skills="$skills echo"
[[ "$prompt" == *"#discuss"* ]] || [[ "$prompt" == *"/discuss"* ]] && skills="$skills discuss"
[[ "$prompt" == *"#plan"* ]] || [[ "$prompt" == *"/plan"* ]] && skills="$skills plan"
[[ "$prompt" == *"#prd"* ]] || [[ "$prompt" == *"/prd"* ]] && skills="$skills prd"
[[ "$prompt" == *"#dig"* ]] || [[ "$prompt" == *"/dig"* ]] && skills="$skills dig"
[[ "$prompt" == *"#team"* ]] || [[ "$prompt" == *"/team"* ]] && skills="$skills team"
[[ "$prompt" == *"#fluent"* ]] || [[ "$prompt" == *"/fluent"* ]] && skills="$skills fluent"
[[ "$prompt" == *"#whys"* ]] || [[ "$prompt" == *"/whys"* ]] && skills="$skills whys"

if [ -n "$skills" ]; then
  echo "The user used skill(s):$skills. You MUST invoke the corresponding skill(s) using the Skill tool before responding."
fi
exit 0
