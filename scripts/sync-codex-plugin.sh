#!/usr/bin/env sh
# Codex 배포본을 Claude Code의 canonical 본문에서 생성한다.
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
canonical_root="$repo_root/plugins/devkit"
codex_root="$repo_root/codex-plugins/devkit"

sync_into() {
  destination=$1
  rm -rf "$destination/skills" "$destination/agents"
  mkdir -p "$destination/skills"

  find "$canonical_root/skills" -type f -name SKILL.md -print | while IFS= read -r source; do
    relative=${source#"$canonical_root/skills/"}
    target="$destination/skills/$relative"
    mkdir -p "$(dirname -- "$target")"
    # Claude 전용 자동 호출 차단 필드는 Codex 스킬 스키마에서 지원하지 않는다.
    sed '/^disable-model-invocation: true$/d' "$source" > "$target"
  done

  cp -R "$canonical_root/agents" "$destination/agents"
}

case ${1:-} in
  '')
    sync_into "$codex_root"
    ;;
  --check)
    temp_root=$(mktemp -d "${TMPDIR:-/tmp}/devkit-codex-sync.XXXXXX")
    trap 'rm -rf "$temp_root"' EXIT HUP INT TERM
    sync_into "$temp_root"
    diff -ru "$codex_root/skills" "$temp_root/skills"
    diff -ru "$codex_root/agents" "$temp_root/agents"
    ;;
  *)
    printf '%s\n' "usage: $0 [--check]" >&2
    exit 2
    ;;
esac
