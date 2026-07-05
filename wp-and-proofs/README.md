# wp-and-proofs — where automation ends and an interactive prover begins

A small, honest example of the **complementarity between an automatic verifier
(Frama-C's WP + SMT solvers) and an interactive theorem prover (Coq)**: WP
discharges the bulk of a proof automatically, but some obligations lie outside
what SMT can decide, and there a theorem prover takes over.

```sh
make          # runs verify.sh: shows [1] SMT proves, [2] SMT fails, [3] Coq proves
make clean
```

## The two files

| File | Property | Who proves it |
|---|---|---|
| **`align.c`** | `align_up_pow2` is memory-safe **and** `*r >= v` | **WP + Alt-Ergo/Z3**, fully automatic (11/11) |
| **`induction.c`** + **`sum_closed.v`** | `2·sum(n) == n·(n+1)` for a recursively-defined `sum` | **WP+SMT cannot**; **Coq** does (admit-free) |

- `align.c` is `align_up_pow2` **extracted verbatim from `peimage/`** (the PE-image
  loader). Its correctness rests on run-time-safety plus a bitwise fact
  (`x & (a-1) <= a-1`); WP generates the obligations and the SMT solvers discharge
  **all of them** with no human help. This is the automation half.
- `induction.c` states a lemma about a recursively-defined `sum(n)`. Proving
  `2·sum(n) == n·(n+1)` requires **induction on `n`** — and SMT solvers do not do
  induction. WP emits the goal; Alt-Ergo/Z3 fail (0/1). `sum_closed.v` proves the
  **same statement, with the same recursive definition**, in Coq by `natlike_ind`
  — admit-free (`Print Assumptions` shows only the definition of `sum`).

## Why this is the honest example (a note on peimage)

The instinct was to lift the "needs a theorem prover" case straight out of
`peimage`. On close inspection that story does **not** hold: `peimage`'s bitwise
obligations — including `x & m <= m` under WP's default encoding — are in fact
discharged by Alt-Ergo/Z3 here. (An earlier Coq detour on `align_up_pow2` was a
mis-diagnosis: the real fix was a missing precondition, `requires a >= 1`, without
which the goal is simply *false* at `a == 0` via unsigned wraparound.) So peimage
by itself does **not** demonstrate the complementarity — its SMT-side is complete.

What genuinely defeats an SMT solver is a different kind of obligation:
**induction over a recursive definition**. That is a categorical gap (SMT decides
quantifier-free/limited theories; it does not perform induction), not a solver
tuning issue — so it is the honest way to show where an interactive prover is
*required*. `align.c` keeps the real peimage code for the automation half;
`induction.c`/`sum_closed.v` supply the genuine theorem-prover half.

## The division of labour

- **WP** is the orchestrator: it turns C + ACSL into proof obligations and
  dispatches them. Most go to SMT and are closed instantly.
- **SMT (Alt-Ergo, Z3)** is complete-enough for arithmetic, memory, and a
  surprising amount of bitwise reasoning — but it does not do induction, and its
  bitvector reasoning has edges (see `../../bugs-to-report/wp-bitwise-smt-incompleteness/`).
- **Coq** supplies exactly the obligations SMT cannot: here, the inductive step.
  Frama-C/WP can even dispatch to Coq directly (`-wp-prover coq` with a proof
  script); this toy keeps the Coq proof standalone (`coqc sum_closed.v`) so it is
  dependency-light and the "same statement, two provers" contrast is explicit.

The point: neither tool alone is enough for the general case. Automation carries
the bulk; the interactive prover carries the residue that is provably beyond it.

## Toolchain

Frama-C 32.1 (WP) · Alt-Ergo 2.6.2 · Z3 4.13.3 · Coq 8.20.1. Nothing is meant to
be committed; `make clean` removes the Coq build artefacts.
