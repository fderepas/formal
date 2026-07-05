(* Small driver: convert int <-> Rocq's unary nat, run the extracted gcd. *)
open Rocq_gcd
let rec nat_of_int n = if n <= 0 then O else S (nat_of_int (n - 1))
let rec int_of_nat = function O -> 0 | S k -> 1 + int_of_nat k
let gcd a b = int_of_nat (rocq_gcd (nat_of_int a) (nat_of_int b))
let () =
  Printf.printf "gcd(252, 105)  = %d\n" (gcd 252 105);
  Printf.printf "gcd(1071, 462) = %d\n" (gcd 1071 462)
