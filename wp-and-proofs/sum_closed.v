(*
  The Coq counterpart of induction.c's `sum_closed` lemma.

  Frama-C/WP + SMT (Alt-Ergo, Z3) cannot prove `2*sum(n) = n*(n+1)`: it needs
  INDUCTION on n, and SMT solvers do not do induction.  Here the SAME statement
  -- with the SAME recursive definition of `sum` -- is proved in Coq, admit-free.
  That is the "interactive theorem prover closes what the automatic solver
  cannot" half of the complementarity.

  Check:  coqc sum_closed.v   (silent success = proved)
*)
Require Import ZArith Lia.
Open Scope Z_scope.

(* mirrors the ACSL:  logic integer sum(integer n); axiom sum_0; axiom sum_n; *)
Parameter sum : Z -> Z.
Axiom sum_0 : sum 0 = 0.
Axiom sum_n : forall n, 0 < n -> n + sum (n - 1) = sum n.

(* mirrors:  lemma sum_closed: \forall integer n; n>=0 ==> 2*sum(n) == n*(n+1); *)
Theorem sum_closed : forall n, 0 <= n -> 2 * sum n = n * (n + 1).
Proof.
  intros n Hn. revert n Hn.
  apply natlike_ind.                          (* induction on n >= 0 *)
  - rewrite sum_0. ring.                       (* base: 2*sum 0 = 0 *)
  - intros x Hx IH.                            (* step: assume for x, show for x+1 *)
    assert (Hs : sum (Z.succ x) = Z.succ x + sum x).
    { pose proof (sum_n (Z.succ x) ltac:(lia)) as H.
      replace (Z.succ x - 1) with x in H by lia. lia. }
    rewrite Hs. replace (Z.succ x) with (x + 1) by lia. nia.
Qed.

(* No `Admitted`, no extra axioms beyond the recursive definition of `sum`: *)
Print Assumptions sum_closed.
