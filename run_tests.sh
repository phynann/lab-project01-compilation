#!/usr/bin/env bash
# Run every test through the scanner and compare with expected output.
# Writes actual output and tests/results.md. Run ./build.sh first.
cd "$(dirname "$0")"

# Support both test/ and tests/ directory structures
IN_DIR="test/input"
EXP_DIR="test/expected"
ACT_DIR="test/actual"

if [ ! -d "$IN_DIR" ] && [ -d "tests/inputs" ]; then
  IN_DIR="tests/inputs"
  EXP_DIR="tests/expected"
  ACT_DIR="tests/actual"
fi

mkdir -p "$ACT_DIR" "tests/actual" 2>/dev/null
pass=0; fail=0
{
echo "| Test | Kind | First Line | Result |"
echo "|------|------|------------|--------|"
for f in "$IN_DIR"/*.txt; do
  [ -e "$f" ] || continue
  id=$(basename "$f" .txt)
  case $id in
    *norm*|N*) kind=normal;;
    *bound*|B*) kind=boundary;;
    *inv*|E*) kind=invalid;;
    *) kind=other;;
  esac
  java -cp out taskscan.Main "$f" > "$ACT_DIR/$id.out" 2>/dev/null
  cp "$ACT_DIR/$id.out" "tests/actual/$id.out" 2>/dev/null || true
  if diff -q --strip-trailing-cr "$EXP_DIR/$id.out" "$ACT_DIR/$id.out" >/dev/null 2>&1 || diff -q "$EXP_DIR/$id.out" "$ACT_DIR/$id.out" >/dev/null 2>&1; then
    r=PASS
    pass=$((pass+1))
  else
    r=FAIL
    fail=$((fail+1))
  fi
  shown=$(head -n 1 "$f" 2>/dev/null | tr -d '\r\n' | sed 's/|/\\|/g')
  echo "| $id | $kind | \`$shown\` | $r |"
done
echo
echo "Total: $((pass+fail)) tests, $pass passed, $fail failed"
} | tee tests/results.md
[ "$fail" -eq 0 ]
