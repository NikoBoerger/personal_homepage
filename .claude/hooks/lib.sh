# Shared helpers for skill-hint hooks. Sourced by the hook scripts in this dir.
#
# Reads the hook JSON from stdin ONCE into $INPUT and derives $PROJECT_DIR.
# The hooks never name specific skills: they detect the KIND of work underway
# and nudge "check your available skills and load any that apply". That stays
# correct as skills are renamed/added and works for teammates whose repo has
# differently-named forks — they just consult whatever skills they have.
#
# Seeding: when the GLOBAL copy of a hook fires in a git repo, it copies these
# scripts into the repo's own .claude/hooks/, records HOOKS_VERSION in
# .claude/hooks/.version, and registers them in the repo's git-tracked
# .claude/settings.json (referenced via the portable $CLAUDE_PROJECT_DIR). The
# repo then owns the hooks and teammates inherit them on checkout, and the
# global copy self-suppresses there (defer_if_project_owns) so a hook never
# fires twice.
#
# Upgrading: raise HOOKS_VERSION whenever a script changes or a new hook joins
# the set. A repo holding an older copy is re-synced on the next fire, and the
# global copy handles that one event itself instead of deferring to the stale
# project copy — otherwise a newly added hook would be silent in every repo
# that was seeded before it existed.

HOOKS_VERSION=5

INPUT="$(cat)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$INPUT" | jq -r '.cwd // ""')}"
SESSION_CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // ""')"

# Where the canonical (global) scripts live, and the repo they live in (which
# must never be seeded into itself).
GLOBAL_HOOKS_DIR="/Users/niko/workspace/claude-context/hooks"
GLOBAL_HOOKS_REPO="/Users/niko/workspace/claude-context"
HOOK_SCRIPTS="lib.sh write-edit-skills.sh bash-edit-skills.sh prompt-skills.sh skill-companions.sh"
# Presence of this file inside a project's .claude/hooks/ means the project
# owns its own copy of the hooks.
SEED_MARKER="write-edit-skills.sh"
JUST_SYNCED=0

NL='
'

# field <jq-filter> -> value from the hook input
field() { printf '%s' "$INPUT" | jq -r "$1"; }

# emit <event-name> <context-string> — print the hook JSON (nothing if empty)
emit() {
  [ -n "$2" ] || return 0
  jq -n --arg e "$1" --arg c "$2" \
    '{hookSpecificOutput:{hookEventName:$e, additionalContext:$c}}'
}

# True when this script is running as the global copy (not a project's own copy
# under <project>/.claude/hooks/).
running_as_global() {
  self="$0"
  case "$self" in
    /*) ;;
    *) self="$(cd "$(dirname "$self")" 2>/dev/null && pwd)/$(basename "$self")" ;;
  esac
  case "$self" in
    "$PROJECT_DIR"/.claude/hooks/*) return 1 ;;
    *) return 0 ;;
  esac
}

# Hook-set version the current project owns: 0 when it owns none, 1 when it was
# seeded before versions existed.
project_hooks_version() {
  if [ -z "$PROJECT_DIR" ] || [ ! -f "$PROJECT_DIR/.claude/hooks/$SEED_MARKER" ]; then
    echo 0
    return 0
  fi
  v="$(cat "$PROJECT_DIR/.claude/hooks/.version" 2>/dev/null)"
  case "$v" in
    ''|*[!0-9]*) echo 1 ;;
    *) echo "$v" ;;
  esac
}

# Copy the hook scripts into the project and register them in the project's
# git-tracked .claude/settings.json so the repo owns them and teammates inherit
# them. Only from the global copy, only inside a git repo, never the
# claude-context repo, skippable via .claude/.no-skill-hooks, idempotent, and
# never clobbers existing project settings (atomic write, validated first).
project_tracks_hook() {
  git -C "$PROJECT_DIR" ls-files --error-unmatch ".claude/hooks/$1" >/dev/null 2>&1
}

sync_project_hooks() {
  running_as_global || return 0
  [ -n "$PROJECT_DIR" ] || return 0
  [ "$PROJECT_DIR" = "$GLOBAL_HOOKS_REPO" ] && return 0
  [ -e "$PROJECT_DIR/.git" ] || return 0
  [ -e "$PROJECT_DIR/.claude/.no-skill-hooks" ] && return 0
  project_tracks_hook "$SEED_MARKER" && return 0
  [ "$(project_hooks_version)" -ge "$HOOKS_VERSION" ] && return 0

  dest="$PROJECT_DIR/.claude/hooks"
  mkdir -p "$dest" || return 0
  for f in $HOOK_SCRIPTS; do
    cp "$GLOBAL_HOOKS_DIR/$f" "$dest/$f" 2>/dev/null || return 0
  done

  settings="$PROJECT_DIR/.claude/settings.json"
  tmp="$settings.seed.$$"
  [ -f "$settings" ] || printf '{}\n' > "$settings"
  # $CLAUDE_PROJECT_DIR stays LITERAL in the JSON (single-quoted jq program), so
  # each teammate's shell expands it to their own checkout at hook runtime.
  jq '
    def add($event; $matcher; $cmd):
      .hooks = (.hooks // {})
      | .hooks[$event] = ((.hooks[$event] // []) as $arr
        | if any($arr[]?; (.hooks // []) | any(.[]?; .command == $cmd))
          then $arr
          else $arr + [{matcher: $matcher, hooks: [{type: "command", command: $cmd}]}]
          end);
    add("PreToolUse"; "Write|Edit"; "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/write-edit-skills.sh\"")
    | add("PreToolUse"; "Bash"; "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/bash-edit-skills.sh\"")
    | add("PreToolUse"; "Skill"; "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/skill-companions.sh\"")
    | add("UserPromptSubmit"; ""; "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/prompt-skills.sh\"")
  ' "$settings" > "$tmp" 2>/dev/null && jq -e . "$tmp" >/dev/null 2>&1 && mv "$tmp" "$settings" || rm -f "$tmp"

  printf '%s\n' "$HOOKS_VERSION" > "$dest/.version"
  JUST_SYNCED=1
}

# If we're the global copy and the project owns an up-to-date set, stay silent
# and let the project's committed copy handle this event. A project we just
# upgraded is handled by us this once, since its copy won't see this event.
defer_if_project_owns() {
  running_as_global || return 0
  [ "$JUST_SYNCED" = "1" ] && return 0
  if project_tracks_hook "$SEED_MARKER"; then
    project_tracks_hook "$(basename "$0")" && exit 0
    return 0
  fi
  [ "$(project_hooks_version)" -ge "$HOOKS_VERSION" ] && exit 0
  return 0
}

KINDS=""

add_kind() {
  case "$KINDS" in
    *"- $1$NL"*) return 0 ;;
  esac
  KINDS="$KINDS- $1$NL"
}

abs_path() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s\n' "${SESSION_CWD:-$PWD}/$1" ;;
  esac
}

# Paths that are never the user's source: devices, temp dirs, scratchpads,
# dependency caches and build output.
ignored_path() {
  case "$1" in
    /dev/*|/tmp/*|/private/var/folders/*|/var/folders/*) return 0 ;;
    */node_modules/*|*/.git/*|*/vendor/*|*/dist/*|*/build/*|*/.terraform/*) return 0 ;;
  esac
  return 1
}

# classify_path <path> — append every kind of work this file represents.
classify_path() {
  PATH_RELEVANT=0
  file="$(abs_path "$1")"
  ignored_path "$file" && return 0
  PATH_RELEVANT=1

  if [ -n "$PROJECT_DIR" ]; then
    case "$file" in
      "$PROJECT_DIR"/*) ;;
      *) add_kind "changing a file in a repository OTHER than this session's working directory (its own CLAUDE.md, rules and skills are not loaded for you)" ;;
    esac
  fi

  is_test=0
  case "$file" in
    *_test.*|*.test.*|*.spec.*|*_spec.*|*/test/*|*/tests/*|*/spec/*|*/specs/*) is_test=1 ;;
  esac

  [ "$is_test" -eq 1 ] && add_kind "writing a test (structure, isolation, tiering, coverage, TDD)"

  case "$file" in
    */strings.xml|*.arb|*/lib/*.dart) add_kind "user-facing copy / wording" ;;
  esac

  if [ "$is_test" -eq 0 ]; then
    case "$file" in
      *.dart|*.ts|*.tsx|*.js|*.jsx|*.mjs|*.go|*.rb|*.kt|*.kts|*.java|*.swift|*.py|*.rs|*.c|*.cc|*.cpp|*.h|*.hpp|*.cs|*.scala|*.php|*.ex|*.exs)
        add_kind "production code (style / readability / comment policy)" ;;
    esac
  fi

  case "$file" in
    *.tf|*.tfvars|*.hcl|*.yaml|*.yml|*.sh|*.bash|*.zsh|*Makefile|*Dockerfile)
      add_kind "infrastructure, config, or shell (comment policy, style)" ;;
  esac

  case "$file" in
    */SKILL.md) add_kind "authoring a skill (trigger wording, description length cap, global/project layering)" ;;
  esac
}
