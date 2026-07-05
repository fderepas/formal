# wp-and-proofs — where automation ends and an interactive prover begins

A small example of the **complementarity between an automatic verifier (Frama-C's
WP + SMT solvers) and an interactive theorem prover (Coq)**: WP discharges the
bulk of a proof automatically, but some obligations lie outside what an SMT solver
can decide, and there a theorem prover takes over.

```sh
make          # runs verify.sh: [1] SMT proves, [2] SMT fails, [3] Coq proves
make clean
```

## The two examples

| Files | Property | Who proves it |
|---|---|---|
| **`align.c`** | `align_up_pow2` is memory-safe **and** `*r >= v` | **WP + Alt-Ergo/Z3**, fully automatic (11/11) |
| **`induction.c`** + **`sum_closed.v`** | `2·sum(n) == n·(n+1)` for a recursively-defined `sum` | **WP+SMT cannot**; **Coq** does (admit-free) |

### 1. Automation does the bulk — `align.c`

`align_up_pow2(v, a, r)` rounds `v` up to a multiple of a power-of-two alignment
`a` — the everyday bit-twiddling of allocators, loaders, and filesystems:

```c
uint64_t t;
if (__builtin_add_overflow(v, a - 1, &t)) return false;  // t = v + (a-1)
uint64_t low = t & (a - 1);
*r = t - low;                                             // == t & ~(a-1)
```

From the C plus a one-line ACSL contract (`requires a >= 1; ensures \result ==>
*r >= v;`), Frama-C/WP generates every proof obligation — no overflow, valid
pointer, and the functional bound `*r >= v`, whose correctness rests on the
bitwise fact `x & (a-1) <= a-1` — and Alt-Ergo/Z3 discharge **all 11** with no
human help.

It is tempting to think the *bitwise* reasoning is where an SMT solver would give
out. It isn't: modern solvers handle a great deal of bit-level arithmetic, and
this whole function is automatic. (The `requires a >= 1` matters, though — without
it the postcondition is genuinely *false* at `a == 0`, where `a - 1` wraps to
`UINT64_MAX`; that is a real bug the contract rules out, not a solver limitation.)

### 2. The genuine gap — induction (`induction.c` / `sum_closed.v`)

`induction.c` defines `sum(n)` recursively (`sum(0)=0`, `sum(n)=n+sum(n-1)`) and
asks WP to prove the closed form `2·sum(n) == n·(n+1)`:

```
/*@ lemma sum_closed: \forall integer n; n >= 0 ==> 2 * sum(n) == n * (n + 1); */
```

WP emits the goal; Alt-Ergo/Z3 **fail (0/1)**. This is not a tuning issue: proving
the statement requires **induction on `n`**, and SMT solvers do not perform
induction — they decide (mostly quantifier-free) fragments of fixed theories. It
is a *categorical* limit.

`sum_closed.v` proves the **same statement, with the same recursive definition**,
in Coq — by `natlike_ind`, in a few lines, **admit-free** (`Print Assumptions`
reports only the definition of `sum`, no hidden axioms). This is exactly the
obligation the automatic solvers cannot reach.

## The division of labour

- **WP** turns C + ACSL into proof obligations and dispatches them; most go to SMT
  and close instantly.
- **SMT (Alt-Ergo, Z3)** is complete-enough for arithmetic, memory, and a
  surprising amount of bitwise reasoning — but it does not do induction.
- **Coq** supplies precisely what SMT cannot: here, the inductive step. Frama-C/WP
  can even dispatch to Coq directly (`-wp-prover coq` with a proof script); this
  example keeps the Coq proof standalone (`coqc sum_closed.v`) so it is
  dependency-light and the "same statement, two provers" contrast is explicit.

Neither tool alone suffices for the general case: automation carries the bulk, and
the interactive prover carries the residue that is provably beyond it.

## Toolchain

Frama-C 32.1 (WP) · Alt-Ergo 2.6.2 · Z3 4.13.3 · Coq 8.20.1. `make clean` removes
the Coq build artefacts.
