(*
  A formally verified Euclidean GCD in Rocq (Coq 8.20): proofs of termination
  and functional correctness, then EXTRACTED to executable code.

  NOTE ON THE TARGET LANGUAGE.  Rocq's built-in `Extraction` emits OCaml /
  Haskell / Scheme -- NOT C.  Genuine Rocq -> C is a separate tool, CertiCoq
  (Gallina -> CompCert Clight -> .c), which is not installed in this switch.
  See README.md.  Here we do the real, reproducible thing: prove, then extract
  to OCaml (the closest native target).
*)

Require Import Arith.
Require Import Recdef.               (* the `Function` command *)
Open Scope nat_scope.

(* ---------------------------------------------------------------------- *)
(* 1. Definition + termination proof.                                     *)
(*    `Function ... {measure b}` uses well-founded recursion on the value  *)
(*    of `b`; it emits the obligation `a mod (S n) < S n`, which we close   *)
(*    with the library lemma `Nat.mod_upper_bound`.                        *)
(* ---------------------------------------------------------------------- *)

Function rocq_gcd (a b : nat) {measure (fun n => n) b} : nat :=
  match b with
  | 0 => a
  | S _ => rocq_gcd b (a mod b)
  end.
Proof.
  intros a b n teq.               (* teq : b = S n; goal: a mod S n < S n *)
  apply Nat.mod_upper_bound. discriminate.
Defined.

(* ---------------------------------------------------------------------- *)
(* 2. Number-theory bridges: how divisibility moves across `a mod b`.     *)
(* ---------------------------------------------------------------------- *)

(* If d | b and d | (a mod b) then d | a. *)
Lemma dvd_of_dvd_mod : forall d a b,
  b <> 0 -> Nat.divide d b -> Nat.divide d (a mod b) -> Nat.divide d a.
Proof.
  intros d a b Hb Hdb Hdm.
  rewrite (Nat.div_mod a b Hb).       (* a = b * (a / b) + a mod b *)
  apply Nat.divide_add_r.
  - apply Nat.divide_mul_l. exact Hdb.  (* d | b  =>  d | b * (a / b) *)
  - exact Hdm.
Qed.

(* If d | a and d | b then d | (a mod b). *)
Lemma dvd_mod_of_dvd : forall d a b,
  b <> 0 -> Nat.divide d a -> Nat.divide d b -> Nat.divide d (a mod b).
Proof.
  intros d a b Hb Hda Hdb.
  rewrite (Nat.mod_eq a b Hb).        (* a mod b = a - b * (a / b) *)
  apply Nat.divide_sub_r.
  - exact Hda.
  - apply Nat.divide_mul_l. exact Hdb. (* d | b  =>  d | b * (a / b) *)
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. Functional correctness, via the auto-generated `rocq_gcd_ind`.      *)
(* ---------------------------------------------------------------------- *)

(* Common divisor: rocq_gcd a b divides both a and b (proved together so a  *)
(* single induction hypothesis suffices).                                   *)
Theorem rocq_gcd_dvd : forall a b,
  Nat.divide (rocq_gcd a b) a /\ Nat.divide (rocq_gcd a b) b.
Proof.
  intros a b. functional induction (rocq_gcd a b).
  - (* b = 0: rocq_gcd a 0 = a *)
    split; [ apply Nat.divide_refl | apply Nat.divide_0_r ].
  - (* b = S _; IHn : (d | b) /\ (d | a mod b), d = rocq_gcd b (a mod b) *)
    destruct IHn as [Hb Hmod]. split.
    + (* d | a: b is not in the conclusion, so let `exact Hb` fix it, then b<>0 *)
      eapply dvd_of_dvd_mod; [ | exact Hb | exact Hmod ]. discriminate.
    + exact Hb.
Qed.

Theorem rocq_gcd_dvd_a : forall a b, Nat.divide (rocq_gcd a b) a.
Proof. intros; apply rocq_gcd_dvd. Qed.

Theorem rocq_gcd_dvd_b : forall a b, Nat.divide (rocq_gcd a b) b.
Proof. intros; apply rocq_gcd_dvd. Qed.

(* Greatest: any common divisor of a and b divides rocq_gcd a b. *)
Theorem rocq_gcd_greatest : forall a b c,
  Nat.divide c a -> Nat.divide c b -> Nat.divide c (rocq_gcd a b).
Proof.
  intros a b c. functional induction (rocq_gcd a b); intros Hca Hcb.
  - (* b = 0: rocq_gcd a 0 = a, and c | a is given *)
    exact Hca.
  - (* b = S _: reduce to (b, a mod b) *)
    apply IHn.
    + exact Hcb.
    + (* c | a mod b: b is inferred from the goal `a mod (S _x)` *)
      apply dvd_mod_of_dvd; [ discriminate | exact Hca | exact Hcb ].
Qed.

(* Executable sanity checks (kernel-computed via vm). *)
Example ex1 : rocq_gcd 252 105 = 21.  Proof. vm_compute. reflexivity. Qed.
Example ex2 : rocq_gcd 1071 462 = 21. Proof. vm_compute. reflexivity. Qed.
Example ex3 : rocq_gcd 17 5 = 1.      Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. Extraction. Rocq's native target is OCaml; the proofs are erased.   *)
(* ---------------------------------------------------------------------- *)

Extraction Language OCaml.
Extraction "rocq_gcd.ml" rocq_gcd.
