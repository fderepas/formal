#!/bin/sh
# Correctness comparison of the three generated GCD runners against the reference
# (column 3 of the vectors).  Invoked by `make test`.  Exits non-zero on any FAIL.
set -e
cd "$(dirname "$0")"

# split "a b expected" into inputs and expected outputs
awk '{print $1, $2}' vectors_small.txt > small_in.txt
awk '{print $3}'     vectors_small.txt > small_expected.txt
awk '{print $1, $2}' vectors_big.txt   > big_in.txt
awk '{print $3}'     vectors_big.txt   > big_expected.txt

fail=0
check() {  # label runner infile expfile
  "$2" < "$3" > "$1.out"
  if diff -q "$1.out" "$4" >/dev/null; then
    echo "  PASS  $1 ($(wc -l < "$4" | tr -d ' ') cases)"
  else
    echo "  FAIL  $1"; diff "$1.out" "$4" | head -3; fail=1
  fi
}

echo "Correctness on small vectors (<= 1000; safe for unary Rocq):"
check lean_small       ./lean_gcd        small_in.txt small_expected.txt
check rocq_unary_small ./rocq_gcd_unary  small_in.txt small_expected.txt
check rocq_int_small   ./rocq_gcd_int    small_in.txt small_expected.txt

echo "Correctness on big vectors (up to ~2.8e18; unary Rocq skipped: O(value)):"
check lean_big     ./lean_gcd     big_in.txt big_expected.txt
check rocq_int_big ./rocq_gcd_int big_in.txt big_expected.txt

printf "Cross-check Lean == Rocq-int on big: "
if diff -q lean_big.out rocq_int_big.out >/dev/null; then echo "PASS (identical)"; else echo "FAIL"; fail=1; fi

rm -f *.out small_in.txt small_expected.txt big_in.txt big_expected.txt
if [ "$fail" = 0 ]; then echo "All correctness tests PASSED."; else echo "Some tests FAILED."; exit 1; fi
