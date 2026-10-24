#!/usr/bin/env bash
set -euo pipefail

# 检查覆盖上游的 skill 是否与上游发生漂移。
#
# 1. 对比上游锁定提交（PINNED）与上游 main：上游改了覆盖文件就报告并退出 1。
# 2. 对比锁定提交与本地覆盖版本：改动块数超过 ALLOWED 就退出 1。
#
# 上游更新后：把上游新原文合入本地覆盖文件、保留允许的改动块，再把 PINNED 改成新提交。

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM="mattpocock/skills"
PINNED="5beb35b040e3de97e54fa9e386d7e42d15c295c2"
REF="${1:-main}"

# 本地路径 → 允许与锁定版本不同的改动块数
declare -A ALLOWED=(
  [implement/SKILL.md]=2
  [implement/agents/openai.yaml]=0
  [implement-spec/SKILL.md]=2
  [implement-spec/agents/openai.yaml]=0
)

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fetch() {
  curl -fsSL "https://raw.githubusercontent.com/$UPSTREAM/$1/skills/engineering/$2" -o "$3"
}

status=0
for path in "${!ALLOWED[@]}"; do
  key="${path//\//_}"
  fetch "$PINNED" "$path" "$TMP/$key.pinned"
  fetch "$REF" "$path" "$TMP/$key.latest"

  if ! diff -q "$TMP/$key.pinned" "$TMP/$key.latest" >/dev/null; then
    echo "✗ 上游已修改 $path（$PINNED → $REF）："
    diff -u --label "pinned/$path" --label "$REF/$path" "$TMP/$key.pinned" "$TMP/$key.latest" || true
    status=1
  fi

  hunks="$(diff -U0 "$TMP/$key.pinned" "$REPO/$path" | grep -c '^@@' || true)"
  if (( hunks > ALLOWED[$path] )); then
    echo "✗ 本地 $path 有 $hunks 处改动，允许 ${ALLOWED[$path]} 处："
    diff -u --label "pinned/$path" --label "local/$path" "$TMP/$key.pinned" "$REPO/$path" || true
    status=1
  fi
done

(( status == 0 )) && echo "通过：覆盖文件与上游 $PINNED 一致，仅含允许的改动。"
exit "$status"
