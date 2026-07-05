(*
  The same verified rocq_gcd (the correctness theorems live in Gcd.v), extracted
  with nat -> native OCaml int and mod/div -> native ops.

  The Extract Constant directives are TRUSTED extraction axioms (OCaml `mod`/`/`
  are *assumed* to implement Coq's Nat.modulo/Nat.div, with Coq's div-by-0
  conventions: a mod 0 = a, a / 0 = 0), and native int is 63-bit -- so this
  efficient extraction trades the unboundedness and a slice of the TCB that the
  default (unary) extraction keeps.  See ../tests/RESULTS.md.
*)

Require Import Arith Recdef.
Require Import ExtrOcamlNatInt.
Extract Constant Nat.modulo => "(fun x y -> if y = 0 then x else x mod y)".
Extract Constant Nat.div    => "(fun x y -> if y = 0 then 0 else x / y)".
Open Scope nat_scope.

Function rocq_gcd (a b : nat) {measure (fun n => n) b} : nat :=
  match b with
  | 0 => a
  | S _ => rocq_gcd b (a mod b)
  end.
Proof.
  intros a b n teq. apply Nat.mod_upper_bound. discriminate.
Defined.

Extraction Language OCaml.
Extraction "rocq_gcd_int.ml" rocq_gcd.
