#!/bin/sh
set -eu

input=$1
output=$2
base=${input##*/}

case "$base" in
  *.mbt.md) function_name=${base%.mbt.md} ;;
  *.md) function_name=${base%.md} ;;
  *)
    echo "md_to_mbt_string: input must end in .md or .mbt.md: $input" >&2
    exit 1
    ;;
esac

if ! printf '%s\n' "$function_name" | grep -Eq '^[a-z_][A-Za-z0-9_]*$'; then
  echo "md_to_mbt_string: input basename is not a MoonBit function name: $function_name" >&2
  exit 1
fi

tmp="${output}.tmp"

{
  printf '%s\n' "// Generated from $base by moon dev_build. DO NOT EDIT."
  printf '%s\n' '///|'
  printf '%s\n' "fn ${function_name}() -> String {"
  printf '%s\n' '  ('
  sed 's/^/    #|/' "$input"
  printf '%s\n' '  )'
  printf '%s\n' '}'
} > "$tmp"

mv "$tmp" "$output"
