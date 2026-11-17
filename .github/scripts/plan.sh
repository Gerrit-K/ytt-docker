#!/usr/bin/env bash
# Prints a JSON build matrix: [{version, go, push, tags}].
# Env: MODE = new | latest | push-latest | version:<vX.Y.Z>
#   new          upstream releases newer than the newest image on Docker Hub (push)
#   latest       newest upstream release, build and test only
#   push-latest  newest upstream release, build, test and push
#   version:<v>  one given release, build, test and push
set -euo pipefail

IMAGE=${IMAGE:-gerritk/ytt}
UPSTREAM=carvel-dev/ytt
MODE=${MODE:?}

# stable upstream releases, oldest first
releases=$(curl -fsS "https://api.github.com/repos/$UPSTREAM/releases?per_page=100" \
  | jq -r '.[] | select(.prerelease == false and .draft == false) | .tag_name' \
  | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V)
newest=$(tail -n1 <<<"$releases")

case "$MODE" in
  latest)      select=$newest; push=false ;;
  push-latest) select=$newest; push=true ;;
  version:*)   select=${MODE#version:}; push=true
               grep -qx "$select" <<<"$releases" || { echo "unknown release $select" >&2; exit 1; } ;;
  new)
    published=$(curl -fsS "https://hub.docker.com/v2/repositories/$IMAGE/tags?page_size=100&ordering=last_updated" \
      | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
    select=$(printf 'v%s\n%s\n' "$published" "$releases" | sort -V | uniq | awk -v p="v$published" 'f{print} $0==p{f=1}')
    push=true ;;
  *) echo "bad MODE $MODE" >&2; exit 1 ;;
esac

for v in $select; do
  ver=${v#v}
  minor=${ver%.*}
  major=${ver%%.*}
  tags="$IMAGE:$ver"
  [ "$(grep -E "^v$minor\.[0-9]+$" <<<"$releases" | tail -n1)" = "$v" ] && tags+=",$IMAGE:$minor"
  [ "$major" != 0 ] && [ "$(grep -E "^v$major\." <<<"$releases" | tail -n1)" = "$v" ] && tags+=",$IMAGE:$major"
  [ "$newest" = "$v" ] && tags+=",$IMAGE:latest"
  go=$(curl -fsS "https://raw.githubusercontent.com/$UPSTREAM/$v/go.mod" | awk '$1=="go"{print $2; exit}')
  if ! docker manifest inspect "golang:$go-trixie" >/dev/null 2>&1; then
    go=$(cut -d. -f1,2 <<<"$go")
  fi
  jq -nc --arg version "$v" --arg go "$go" --argjson push "$push" --arg tags "$tags" \
    '{version:$version, go:$go, push:$push, tags:$tags}'
done | jq -sc .
