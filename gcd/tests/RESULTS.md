# Extended tests: Lean- vs Rocq-generated GCD

Comparison of the **generated code** from the two proven GCDs in `../lean/` and
`../rocq/`. All three implementations below are the *same proven Euclidean
algorithm*; they differ only in the number representation the code
generator / extraction uses — which turns out to dominate everything.

## Implementations under test

| Tag | From | Codegen | Number type |
|---|---|---|---|
| **Lean** | `../lean/Gcd.lean` (`myGcd`) | Lean → **C** → native (`leanc`) | `Nat` = unbounded bignum (proven) |
| **Rocq-unary** | `../rocq/Gcd.v` (`rocq_gcd`) | Rocq `Extraction` → **OCaml** → native | `nat` = unary Peano `O`/`S` (proven) |
| **Rocq-int** | same, `ExtrOcamlNatInt` + native `mod` | Rocq `Extraction` → **OCaml** → native | native 63-bit `int` (see caveat) |

Test vectors (deterministic, `gen_vectors.py`, reference = Python `math.gcd`):
- `vectors_small.txt` — **416** pairs, values ≤ 1000 (safe for unary).
- `vectors_big.txt` — **204** pairs, values up to ~2.8×10¹⁸ (incl. the Fibonacci
  worst case for Euclid).
- `stress_big.txt` — **100 000** random pairs, values up to 10⁹.

## Correctness — all three are correct where they can run

| Workload | Lean | Rocq-unary | Rocq-int |
|---|---|---|---|
| small (416, ≤1000) | ✅ all match ref | ✅ all match ref | ✅ all match ref |
| big (204, ≤2.8e18) | ✅ all match ref | — cannot run¹ | ✅ all match ref |
| stress (100 000) | ✅ | — cannot run¹ | ✅ (identical to Lean) |

Outputs are **byte-identical** across implementations wherever both run — the
proof survives codegen intact.
¹ unary Peano cannot even *represent* these values (see below).

## Performance

### ⚠️ Measure compute, not the harness

An earlier version of this file reported Lean 6.28 s vs Rocq-int 0.12 s on 100 000
pairs and called it a 50× gap. **That was wrong** — it measured *I/O and parsing*,
not gcd. Isolating the harness confirms it: a Lean program that reads+parses+prints
the 100 000 pairs **with no gcd at all** takes **5.33 s** (my Lean driver splits the
*whole* input string and `IO.println`s per line — slow), while the 100 000 gcd calls
are ~0.08 s of that. OCaml's `input_line`/`Printf` does the same I/O in ~0.1 s. So
the 50× was the driver, not the generated code.

### Compute-bound: the actual generated gcd (10 000 000 calls, one line out)

| | Lean (C) | Rocq-int (OCaml) |
|---|---|---|
| 10⁷ × gcd(i+10⁹, 998244353), best of 3 | **7.44 s** | **2.30 s** |

**≈ 3.2×**, not 50×. And even this is not a like-for-like: Lean's `Nat` is an
*unbounded* object (tagged small-int fast path, bignum above 2⁶³) reached through
`lean_object*` calls; Rocq-int is an *unboxed 63-bit* native `int`. Lean is paying
~3× for unboundedness + its object model — a guarantee Rocq-int doesn't offer
(it silently overflows past 2⁶³).

### Rocq-unary's wall — linear in the *value*

The default extraction (`nat` = unary `S`/`O`) strips constructors one at a time, so
time grows with the numeric value, not its bit-length:

| gcd(v, v−1) | v = 2·10⁴ | 2·10⁵ | 2·10⁶ | 2·10⁷ |
|---|---|---|---|---|
| Rocq-unary | 0.00 s | 0.03 s | 0.60 s | 4.79 s |

A single 10⁹ gcd would take minutes and multiple GB of RAM (it literally builds a
10⁹-deep linked list). Correct, but unusable at scale — and this *is* a real
order-of-magnitude difference from the other two.

## Findings

1. **The proof is orthogonal to performance.** Identical, verified algorithm;
   the large spread between unary and int-Rocq comes entirely from the extraction
   directive, not the maths.

0. **Benchmark the code, not the harness.** The headline lesson of this exercise:
   the first "50×" number was I/O + string-parsing overhead in a naive Lean driver,
   not the gcd (see the ⚠️ above). Isolating computation, Lean is ~3.2× slower than
   native-int Rocq — a real but modest gap, for real reasons (below).

2. **Rocq's *default* extraction is a performance trap.** `nat` extracts to unary
   Peano — O(value) in both time and space. Fine for a demo, unusable for real
   inputs. This is the single biggest practical difference from Lean, whose `Nat`
   is a bignum out of the box.

3. **Making Rocq fast costs trust and bounds.** `ExtrOcamlNatInt` was *not enough*
   on its own — the extracted `Nat.modulo` stays O(value) (it's the stdlib's
   structural `divmod`) until you *also* `Extract Constant Nat.modulo => "…mod…"`.
   Those `Extract Constant` directives are **trusted axioms** (the OCaml `mod` is
   *assumed* to implement Coq's `Nat.modulo`), and native `int` is **63-bit** — so
   Rocq-int trades away both the unboundedness and a slice of the proof's TCB for
   its speed.

4. **The genuinely fair comparison** (same guarantee level) would pit Lean's
   proven unbounded `Nat` against a Rocq development over `Z` extracted with
   `ExtrOcamlZBigInt` (→ zarith bignum). Both would be correct-and-unbounded, and
   both bignum-speed — the Rocq-int number here is faster precisely because it is
   *not* offering the same guarantee.

5. **The residual ~3.2× (compute-bound) is Lean's `Nat` object model** — tagged
   small-int fast path but still reached through `lean_object*` calls, vs OCaml's
   unboxed native `int`. It buys unboundedness and freedom from extraction axioms —
   exactly what Rocq-int trades away. A Lean `Nat` and a Rocq `Z`/zarith would land
   much closer, both bignum-correct.

## Reproduce

```sh
python3 gen_vectors.py
# Lean:      lean -c LeanBatch.c LeanBatch.lean && leanc LeanBatch.c -o lean_gcd
# Rocq-unary: ocamlopt rocq_gcd.mli rocq_gcd.ml rocq_batch.ml -o rocq_gcd_unary
# Rocq-int:   ocamlopt rocq_gcd_int.mli rocq_gcd_int.ml rocq_batch_int.ml -o rocq_gcd_int
awk '{print $1,$2}' vectors_small.txt | ./lean_gcd | diff - <(awk '{print $3}' vectors_small.txt)
```

Binaries / `*.cmi|*.cmx|*.o` / generated `*.c` are build artifacts (not kept).
