#!/bin/bash
# Test script for Tree-sitter Mux grammar

set -euo pipefail

sample_file=$(mktemp "${TMPDIR:-/tmp}/tree-sitter-mux-sample.XXXXXX")
trap 'rm -f "$sample_file"' EXIT

echo "=== Testing Tree-sitter Mux Grammar ==="
echo

echo "1. Testing parser generation..."
tree-sitter generate grammar.js
echo "   Parser generated successfully"
echo

echo "2. Testing parsing (pipe input)..."
echo 'func main() returns void { auto x = 42 }' | tree-sitter parse
echo

echo "3. Testing parsing (file input)..."
echo 'auto y = "hello"' > "$sample_file"
tree-sitter parse "$sample_file"
echo

echo "4. Testing corpus tests..."
tree-sitter test
echo

echo "5. Testing highlighting (if configured)..."
if [[ -f "test.mux" ]]; then
  highlight_output=$(tree-sitter highlight --scope source.mux test.mux 2>&1)
  if [[ -z "$highlight_output" ]]; then
    echo "Highlighting produced no output" >&2
    exit 1
  fi
  if grep -Fqi "No language found" <<<"$highlight_output"; then
    echo "Mux grammar was not loaded for highlighting" >&2
    exit 1
  fi
  head -20 <<<"$highlight_output"
else
  echo "   No test.mux file found, skipping highlight test"
fi
echo

echo "=== All tests completed ==="
