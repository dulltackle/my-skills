#!/usr/bin/env bash
set -euo pipefail

# 检查覆盖上游的 skill 是否与上游最新版保持一致。
#
# 拉取上游 main（或第一个参数指定的 ref）上的覆盖文件，与本地版本对比：
# 改动块数超过 ALLOWED 说明上游在别处有更新，打印 diff 并退出 1。
# 处理方式：把上游新原文合入本地覆盖文件，只保留允许的改动块，再重跑直到通过。

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM="mattpocock/skills"
REF="${1:-main}"

# 本地路径 → 允许与上游不同的改动块数
declare -A ALLOWED=(
  [implement/SKILL.md]=2
  [implement/agents/openai.yaml]=0
  [implement-spec/SKILL.md]=2
  [implement-spec/agents/openai.yaml]=0
)

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 依次精确匹配分支、标签；都不是则视为提交 SHA
sha="$(git ls-remote "https://github.com/$UPSTREAM" "refs/heads/$REF" "refs/tags/$REF" | cut -f1 | head -n1)"
sha="${sha:-$REF}"
[[ -n "$sha" ]] || { echo "✗ 无法解析上游 $REF"; exit 1; }

status=0
for path in "${!ALLOWED[@]}"; do
  upstream="$TMP/${path//\//_}"
  curl -fsSL "https://raw.githubusercontent.com/$UPSTREAM/$sha/skills/engineering/$path" -o "$upstream"

  hunks="$(diff -U0 "$upstream" "$REPO/$path" | grep -c '^@@' || true)"
  if (( hunks > ALLOWED[$path] )); then
    echo "✗ $path 与上游 ${sha:0:7} 有 $hunks 处不同，允许 ${ALLOWED[$path]} 处："
    diff -u --label "upstream/$path" --label "local/$path" "$upstream" "$REPO/$path" || true
    status=1
  fi
done

(( status == 0 )) && echo "通过：覆盖文件与上游 $REF（${sha:0:7}）一致，仅含允许的改动。"
exit "$status"
