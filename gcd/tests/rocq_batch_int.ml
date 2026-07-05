(* Rocq-extracted gcd with nat->native-int mapping. No O(value) conversion. *)
open Rocq_gcd_int
let () =
  try while true do
    let line = String.trim (input_line stdin) in
    match List.filter (fun s -> s <> "") (String.split_on_char ' ' line) with
    | a :: b :: _ -> Printf.printf "%d\n" (rocq_gcd (int_of_string a) (int_of_string b))
    | _ -> ()
  done with End_of_file -> ()
