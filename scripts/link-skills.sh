#!/usr/bin/env bash
set -euo pipefail

# Symlink every skill in this repo into the local harness skill directories,
# so edits here are live and a `git pull` keeps installed skills current:
#   ~/.claude/skills   Claude Code
#   ~/.agents/skills   Codex and other Agent Skills compatible harnesses
# Re-run after adding, removing, or renaming a skill. If you installed the
# plugin instead, you don't need this: you would get every skill twice.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

for DEST in "${DESTS[@]}"; do
  if [ -L "$DEST" ]; then
    resolved="$(readlink "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo; remove it and re-run." >&2
        exit 1
        ;;
    esac
  fi
  mkdir -p "$DEST"

  for skill_md in "$REPO"/skills/*/SKILL.md; do
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"
    target="$DEST/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "skip $name: $target exists and is not a symlink" >&2
      continue
    fi
    ln -sfn "$src" "$target"
    echo "linked $name -> $src ($DEST)"
  done
done
