#!/bin/sh
# PreToolUse hook for Write|Edit. Detects the KIND of file being written and
# nudges to check for applicable skills before writing. Never names a skill —
# it describes the work, so it stays correct across skill renames and works for
# teammates whose repo has differently-named forks.

. "$(dirname "$0")/lib.sh"

sync_project_hooks
defer_if_project_owns

FILE="$(field '.tool_input.file_path // ""')"
[ -n "$FILE" ] || exit 0

classify_path "$FILE"

[ -n "$KINDS" ] || exit 0
emit PreToolUse "Editing $FILE — before you write, check your available skills and load any that apply to:$NL$KINDS"
