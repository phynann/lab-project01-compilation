#!/usr/bin/env bash
# Run every tests/inputs/*.txt through the scanner and compare with tests/expected/*.out.
# Writes tests/actual/*.out and tests/results.md. Run ./build.sh first.
cd "$(dirname "$0")"
mkdir -p tests/actual
pass=0; fail=0
{
echo "| Test | Kind | Input (escaped) | Result |"
echo "|------|------|-----------------|--------|"
for f in tests/inputs/*.txt; do
  id=$(basename "$f" .txt)
  case $id in N*) kind=normal;; B*) kind=boundary;; E*) kind=invalid;; esac
  java -cp out taskscan.Main "$f" > "tests/actual/$id.out" 2>/dev/null
  if diff -q "tests/expected/$id.out" "tests/actual/$id.out" >/dev/null; then r=PASS; pass=$((pass+1)); else r=FAIL; fail=$((fail+1)); fi
  shown=$(python3 -c 'import sys;print(repr(open(sys.argv[1],encoding="utf-8",newline="").read()).replace("|","\\|"))' "$f")
  echo "| $id | $kind | \`$shown\` | $r |"
done
echo
echo "Total: $((pass+fail)) tests, $pass passed, $fail failed"
} | tee tests/results.md
[ "$fail" -eq 0 ]
