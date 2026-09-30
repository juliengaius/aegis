#!/usr/bin/env bash
# Runs every Aegis testbench with Icarus Verilog (free, open source).
# Usage: ./sim/run_tests.sh        (from the repo root)
# Exits non-zero if any testbench fails, so CI can use it directly.

set -u
cd "$(dirname "$0")/.."
mkdir -p build

# name | files (RTL first, then testbench)
TESTS=(
  "market_pack_decoder|rtl/market_pack_decoder.sv tb/market_packet_decoder_tb.sv"
  "order_decoder|rtl/order_decoder.sv tb/order_decoder_tb.sv"
  "top_of_book|rtl/top_of_book.sv tb/top_of_book_tb.sv"
  "decoder+book integration|rtl/market_pack_decoder.sv rtl/top_of_book.sv tb/market_pipeline_tb.sv"
  "market_data_pipeline (top level)|rtl/market_pack_decoder.sv rtl/top_of_book.sv rtl/market_data_pipeline.sv tb/market_data_pipeline_tb.sv"
)

total_pass=0
failed=0

for t in "${TESTS[@]}"; do
  name="${t%%|*}"
  files="${t#*|}"
  out="build/$(echo "$name" | tr -c 'a-zA-Z0-9' '_').vvp"
  echo "=== $name"
  if ! iverilog -g2012 -o "$out" $files; then
    echo "COMPILE FAILED"; failed=$((failed + 1)); continue
  fi
  log="$(vvp -n "$out" 2>&1)"
  echo "$log" | grep -E "PASS|FAIL|FATAL"
  n=$(echo "$log" | grep -c "^PASS:")
  total_pass=$((total_pass + n))
  if echo "$log" | grep -qE "FAIL|FATAL|fatal"; then
    failed=$((failed + 1))
  fi
done

echo
echo "Checks passed: $total_pass | Testbenches failed: $failed / ${#TESTS[@]}"
[ "$failed" -eq 0 ]
