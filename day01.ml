#!/usr/bin/env ocaml
(* The OCaml toplevel, version 4.12.0 *)

(* https://ocaml.org/learn/tutorials/streams.html *)
let line_stream_of_channel channel =
  Stream.from (fun _ ->
    try Some (input_line channel) with End_of_file -> None)

let stream_map f stream =
  let rec next i =
    try Some (f (Stream.next stream))
    with Stream.Failure -> None in
  Stream.from next

let stream_fold f init stream =
  let result = ref init in
  Stream.iter
    (fun x -> result := f !result x)
    stream;
  !result

let answer1 =
  let line_stream = line_stream_of_channel (open_in "day01.txt") in
  let int_stream = stream_map int_of_string line_stream in
  stream_fold ( + ) 0 int_stream

let () = Printf.printf "answer 1: %d\n" answer1

let cycle items =
  let buf = ref [] in
  let next i =
    if !buf = [] then buf := items;
    match !buf with
      | h :: t -> (buf := t; Some h)
      | [] -> None in
  Stream.from next

module IntSet = Set.Make(Int)

let rec withdraw_until_seen out_stream seen sum =
  let s = sum + (Stream.next out_stream) in
    if IntSet.mem s seen then s
    else withdraw_until_seen out_stream (IntSet.add s seen) s

let answer2 =
  let line_stream = line_stream_of_channel (open_in "day01.txt") in
  let int_stream = stream_map int_of_string line_stream in
  let int_list = stream_fold (fun acc i -> acc @ [i]) [] int_stream in
  let cycle_int_stream = cycle int_list in
    withdraw_until_seen cycle_int_stream (IntSet.singleton 0) 0

let () = Printf.printf "answer 2: %d\n" answer2
