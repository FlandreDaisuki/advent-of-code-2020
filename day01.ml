#!/usr/bin/env ocaml

(* https://ocaml.org/learn/tutorials/streams.html *)
let line_stream_of_channel channel =
  Stream.from (fun _ ->
    try Some (input_line channel) with End_of_file -> None)

let stream_map f stream =
  let rec next i =
    try Some (f (Stream.next stream))
    with Stream.Failure -> None in
  Stream.from next

let stream_fold f stream init =
  let result = ref init in
  Stream.iter
    (fun x -> result := f x !result)
    stream;
  !result

let line_stream = line_stream_of_channel (open_in "day01.txt")

let int_stream = stream_map int_of_string line_stream

let answer1 = stream_fold ( + ) int_stream 0

let () = Printf.printf "answer 1: %d\n" answer1
