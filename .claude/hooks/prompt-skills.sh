#!/bin/sh
# UserPromptSubmit hook. Scans the prompt for intent that maps to work a skill
# might cover but that has no file-path signal, and nudges to check for
# applicable skills. Never names a skill — it describes the work. Keyword lists
# are kept tight so this doesn't fire on every message.

. "$(dirname "$0")/lib.sh"

sync_project_hooks
defer_if_project_owns

PROMPT="$(field '.prompt // ""' | tr '[:upper:]' '[:lower:]')"
[ -n "$PROMPT" ] || exit 0

add() { add_kind "$1"; }

case "$PROMPT" in
  *"implement this design"*|*"build this screen"*|*"here's the mockup"*|*"here is the mockup"*|\
  *"make it look like this"*|*"match this design"*|*"like the mockup"*|*"figma.com"*|\
  *"pixel-perfect"*|*"pixel perfect"*|*"from the mockup"*|*"build this component"*)
    add "building from a visual design" ;;
esac

case "$PROMPT" in
  *"/ce-compound"*|*"that worked"*|*"it's fixed"*|*"its fixed"*|*"problem solved"*|\
  *"capture this learning"*|*"document this learning"*|*"compound this"*|*"let's compound"*|*"lets compound"*)
    add "capturing / compounding a learning" ;;
esac

case "$PROMPT" in
  *"../"*|*"other repo"*|*"another repo"*|*"both repos"*|*"sibling repo"*|*"client repo"*|\
  *"the android client"*|*"the ios client"*|*"infrastructure repo"*|*"babbel.infrastructure"*|\
  *"dotfiles"*|*"git -c "*)
    add "work reaching into a repository other than this session's (its rules and skills are not loaded for you)" ;;
esac

case "$PROMPT" in
  *"open a pr"*|*"create a pr"*|*"raise a pr"*|*"pull request"*|*"pr description"*|*"pr body"*|\
  *"commit message"*|*"write the commit"*)
    add "writing PR or commit prose" ;;
esac

[ -n "$KINDS" ] || exit 0
emit UserPromptSubmit "This request may call for a skill — check your available skills and load any that apply to:$NL$KINDS"
