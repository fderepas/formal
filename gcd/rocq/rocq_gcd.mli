
type nat =
| O
| S of nat

type ('a, 'b) prod =
| Pair of 'a * 'b

val snd : ('a1, 'a2) prod -> 'a2

module Nat :
 sig
  val sub : nat -> nat -> nat

  val divmod : nat -> nat -> nat -> nat -> (nat, nat) prod

  val modulo : nat -> nat -> nat
 end

val rocq_gcd : nat -> nat -> nat
