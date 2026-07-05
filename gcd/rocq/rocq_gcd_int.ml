
module Nat =
 struct
  (** val sub : int -> int -> int **)

  let rec sub n m =
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> n)
      (fun k ->
      (fun fO fS n -> if n=0 then fO () else fS (n-1))
        (fun _ -> n)
        (fun l -> sub k l)
        m)
      n

  (** val divmod : int -> int -> int -> int -> int * int **)

  let rec divmod x y q u =
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> (q, u))
      (fun x' ->
      (fun fO fS n -> if n=0 then fO () else fS (n-1))
        (fun _ -> divmod x' y (Stdlib.Int.succ q) y)
        (fun u' -> divmod x' y q u')
        u)
      x

  (** val modulo : int -> int -> int **)

  let modulo = (fun x y -> if y = 0 then x else x mod y)
 end

(** val rocq_gcd : int -> int -> int **)

let rec rocq_gcd a b =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> a)
    (fun n ->
    rocq_gcd (Stdlib.Int.succ n) (Nat.modulo a (Stdlib.Int.succ n)))
    b
