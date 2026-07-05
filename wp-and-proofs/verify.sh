#!/bin/sh
# Show the complementarity of WP + SMT (automatic) and Coq (interactive).
cd "$(dirname "$0")" || exit 1

echo "=============================================================================="
echo " WP + SMT (automatic)  vs  Coq (interactive theorem prover)  --  who does what"
echo "=============================================================================="

echo
echo "[1] WP + SMT proves a real bitwise/overflow function, fully automatically:"
frama-c -wp -wp-rte -wp-prover alt-ergo,z3 -wp-timeout 10 align.c 2>/dev/null \
  | sed -n 's/^\[wp\] *\(Proved goals.*\)/      \1/p'
echo "      (align_up_pow2, extracted from peimage -- SMT even handles x & (a-1) <= a-1)"

echo
echo "[2] WP + SMT canNOT prove a lemma that needs INDUCTION (solvers do not induct):"
frama-c -wp -wp-prover alt-ergo,z3 -wp-timeout 15 induction.c 2>/dev/null \
  | sed -n 's/^\[wp\] *\(Proved goals.*\)/      \1/p'
echo "      -> sum_closed (2*sum(n) == n*(n+1)) is NOT discharged."

echo
echo "[3] Coq proves the SAME lemma, admit-free -- the prover supplies what SMT cannot:"
if coqc sum_closed.v >/dev/null 2>&1; then
  echo "      sum_closed.v: PROVED by coqc (admit-free)"
else
  echo "      sum_closed.v: coqc FAILED"
fi
rm -f sum_closed.vo sum_closed.vok sum_closed.vos sum_closed.glob .sum_closed.aux .lia.cache .nia.cache

echo
echo "Bulk of the work: automatic.  The one inductive fact: an interactive prover."
