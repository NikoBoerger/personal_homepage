#!/bin/sh
# PreToolUse hook matching the Skill tool. Catches the case where a skill IS
# reached but a companion skill it depends on gets missed, by nudging to check
# for one. Never names a skill — it describes the situation.

. "$(dirname "$0")/lib.sh"

sync_project_hooks
defer_if_project_owns

SKILL="$(field '.tool_input.skill // .tool_input.name // ""')"
[ -n "$SKILL" ] || exit 0

case "$SKILL" in
  *ce-compound)
    emit PreToolUse "You are invoking $SKILL. Before its startup prompts, check your available skills and load any companion/preferences skill that applies." ;;
esac
