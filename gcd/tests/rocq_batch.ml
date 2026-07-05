(* Drives the Rocq-extracted rocq_gcd over stdin pairs.  nat = unary Peano, so
   int<->nat conversion is O(value); tail-recursive to avoid stack overflow. *)
open Rocq_gcd
let nat_of_int n = let rec go acc n = if n <= 0 then acc else go (S acc) (n-1) in go O n
let int_of_nat n = let rec go acc = function O -> acc | S k -> go (acc+1) k in go 0 n
let () =
  try while true do
    let line = String.trim (input_line stdin) in
    match List.filter (fun s -> s <> "") (String.split_on_char ' ' line) with
    | a :: b :: _ ->
      let g = int_of_nat (rocq_gcd (nat_of_int (int_of_string a)) (nat_of_int (int_of_string b))) in
      Printf.printf "%d\n" g
    | _ -> ()
  done with End_of_file -> ()
