#!/usr/bin/env bash
# Generate the scanner with JFlex, then compile everything. Works offline.
set -euo pipefail
cd "$(dirname "$0")"
rm -rf generated/taskscan out && mkdir -p generated/taskscan out
java -jar lib/jflex-full-1.9.1.jar -q -d generated/taskscan src/taskscan/TaskScan.jflex
javac -encoding UTF-8 -d out generated/taskscan/TaskScanner.java src/taskscan/Token.java src/taskscan/TokenType.java src/taskscan/Main.java
echo "build OK -> out/"
