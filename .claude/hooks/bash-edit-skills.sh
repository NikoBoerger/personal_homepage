#!/bin/sh
# PreToolUse hook for Bash. In auto mode most file changes are shell writes
# (heredoc redirects, sed -i, tee, cp/mv) rather than Write|Edit calls, so
# without this hook the whole editing path is unobserved. Extracts the paths a
# command writes to and nudges the same way write-edit-skills.sh does.

. "$(dirname "$0")/lib.sh"

sync_project_hooks
defer_if_project_owns

CMD="$(field '.tool_input.command // ""')"
[ -n "$CMD" ] || exit 0

case "$CMD" in
  *'gh pr create'*|*'gh pr edit'*|*'gh pr comment'*|*'gh pr review'*|*'git commit'*|*'gh api'*'/pulls/'*)
    emit PreToolUse "This command publishes PR or commit prose. Check your available skills and load any that apply to:${NL}  - writing PR or commit prose${NL}A repo-local PR checklist skill does not replace it; both apply."
    ;;
esac

case "$CMD" in
  *'>'*|*'sed -i'*|*'tee '*|*'cp '*|*'mv '*|*'install -'*|*'patch '*|*'git apply'*) ;;
  *'open('*|*'.write('*|*'write_text('*|*'writeFileSync'*|*'File.write'*) ;;
  *) exit 0 ;;
esac

redirect_targets() {
  printf '%s\n' "$CMD" | tr '\n' ' ' | awk '
    {
      for (i = 1; i <= NF; i++) {
        t = $i
        if (t == ">" || t == ">>") { if (i < NF) print $(i + 1); continue }
        if (t ~ /^>>?[^>&]/) { sub(/^>>?/, "", t); print t; continue }
        if (t == "tee") { j = i + 1; while (j <= NF && $j ~ /^-/) j++; if (j <= NF) print $j; continue }
        if (t == "cp" || t == "mv" || t == "patch") { if (NF > i) print $NF; continue }
        if (t == "-i" || t == "--in-place") { if (NF > i) print $NF; continue }
      }
    }'
}

inline_script_targets() {
  case "$CMD" in
    *"open("*"'w'"*|*'open('*'"w"'*|*".write_text("*|*"writeFileSync"*) ;;
    *) return 0 ;;
  esac
  printf '%s\n' "$CMD" | grep -oE "['\"][A-Za-z0-9_./@+-]+\.[A-Za-z0-9]+['\"]" | tr -d "\"'"
}

TARGETS="$( { redirect_targets; inline_script_targets; } | sed "s/^['\"]//; s/['\";)&]*$//" | grep -v '^$' | sort -u | head -8)"
[ -n "$TARGETS" ] || exit 0

FILES=""
for t in $TARGETS; do
  classify_path "$t"
  [ "$PATH_RELEVANT" = "1" ] && FILES="$FILES $t"
done

[ -n "$KINDS" ] || exit 0
emit PreToolUse "This command writes to:$FILES — before it runs, check your available skills and load any that apply to:$NL$KINDS"
