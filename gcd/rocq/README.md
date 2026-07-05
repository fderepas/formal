# gcd/rocq — proven code extracted by Rocq (Coq 8.20)

A verified Euclidean GCD whose *termination* and *functional correctness* are
checked by the Rocq kernel, then **extracted** — proofs erased — to executable
code that compiles and runs.

## ⚠️ On "C": Rocq extracts to OCaml, not C

Unlike Lean 4 (see `../lean/`, which lowers to C natively), **Rocq's built-in
`Extraction` targets OCaml / Haskell / Scheme — not C.** Genuine Rocq → C is a
*separate* tool, **CertiCoq** (Gallina → CompCert Clight → `.c`), which is not
installed in this opam switch — and I did not install it, because it pulls in
CompCert and would risk the `coq-4.14` switch the Frama-C/WP work in this repo
depends on. So this directory does the real, reproducible thing (verify +
extract to OCaml) and documents the CertiCoq recipe for C below.

(The Gemini prompt that motivated this example labelled its output "C", but the
code it printed is in fact OCaml — the same thing shown here.)

## Files
- **`Gcd.v`** — the verified source: the algorithm + termination proof +
  correctness theorems.
- **`rocq_gcd.ml` / `rocq_gcd.mli`** — the code Rocq extracts (`Extraction`).
- **`driver.ml`** — a tiny harness (int ↔ Rocq's unary `nat`) to run it.

## What is proved (kernel-checked, `coqc` exits 0)

1. **Termination.** The recursion `(a, b) → (b, a % b)` is not structural, so we
   use `Function … {measure b}` (well-founded recursion on the value of `b`) and
   discharge the emitted obligation `a mod (S n) < S n` with `Nat.mod_upper_bound`.
2. **Functional correctness** — the full definition of gcd:
   - `rocq_gcd_dvd_a : Nat.divide (rocq_gcd a b) a`
   - `rocq_gcd_dvd_b : Nat.divide (rocq_gcd a b) b`   (**common divisor**), and
   - `rocq_gcd_greatest : ∀ c, c ∣ a → c ∣ b → c ∣ rocq_gcd a b`  (**greatest**).

   Proved by `functional induction` on the principle `rocq_gcd_ind` that
   `Function` auto-generates, so each proof follows the algorithm's own control
   flow; the two divisibility bridges (`d∣b ∧ d∣(a%b) ⇒ d∣a` and its converse)
   come from `Nat.div_mod` / `Nat.mod_eq` + `Nat.divide_{add,sub,mul}_*`. Core
   Rocq only — no Mathlib.

## The extracted code (`rocq_gcd.ml`)

```ocaml
let rec rocq_gcd a = function
| O -> a
| S n -> rocq_gcd (S n) (Nat.modulo a (S n))
```

Everything logical is **gone**: the `measure`, the well-founded/`Acc`
machinery, and every `Theorem` — no `Obj.magic`, no accessibility argument.
What remains is exactly the algorithm the kernel accepted as terminating and
correct. `nat` is Rocq's unary Peano type (`O`/`S`), and `Nat.modulo` is
extracted alongside from the standard library.

## Reproduce

```sh
coqc Gcd.v                                   # 1. check the proofs + emit rocq_gcd.ml/.mli
ocamlopt rocq_gcd.mli rocq_gcd.ml driver.ml -o gcd_demo   # 2. build native
./gcd_demo                                   # 3. run
# gcd(252, 105)  = 21
# gcd(1071, 462) = 21
```

Build artifacts (`gcd_demo`, `*.cmi/*.cmx/*.o`, `Gcd.vo/.glob`) are not kept
here; `rocq_gcd.ml/.mli` regenerate from `Gcd.v` at step 1.

## If you actually want C: the CertiCoq path

`Gcd.v` is CertiCoq-ready. With CertiCoq installed you would add:

```coq
From CertiCoq.Plugin Require Import CertiCoq.
CertiCoq Compile rocq_gcd.     (* emits Clight/C: rocq_gcd.c + glue *)
```

CertiCoq compiles the same Gallina term through CompCert's verified `Clight`
into `.c` — so the C generation itself is proof-carrying. That is the true
Rocq → C story; it just isn't available in this environment.

## The three routes in this repo, side by side

| Route | Direction | Native target |
|---|---|---|
| **Lean** (`../lean/`) | correct-by-construction, then extract | **C** (built in) |
| **Rocq** (here) | correct-by-construction, then extract | **OCaml** (C needs CertiCoq) |
| **Frama-C/WP** ([`../../wp-and-proofs/`](../../wp-and-proofs/README.md)) | verify existing C after the fact | C is the *input* |
