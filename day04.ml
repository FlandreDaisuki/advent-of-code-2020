#!/usr/bin/env -S ocaml str.cma
(* The OCaml toplevel, version 4.12.0 *)

(* The following line will make ocaml-lsp-server unhappy but it's work. *)
(* #load "str.cma";; *)

open Printf;;
Printexc.record_backtrace true;;

let line_stream_of_channel channel =
  Stream.from (fun _ ->
    try Some (input_line channel) with End_of_file -> None)
;;

let stream_fold f init stream =
  let result = ref init in
  Stream.iter
    (fun x -> result := f !result x)
    stream;
  !result
;;

let lines =
  let line_stream = line_stream_of_channel (open_in "day04.txt") in
  stream_fold (fun acc i -> acc @ [i]) [] line_stream
;;

module Date = struct
  type t = { year: int; month: int; day: int; }
  let init (year, month, day) = { year = year; month = month; day = day; }
  let compare first second =
    let diff_year = first.year - second.year in
    let diff_month = first.month - second.month in
    let diff_day = first.day - second.day in
    if diff_year != 0 then diff_year
    else if diff_month != 0 then diff_month
    else diff_day
  let to_string src = sprintf "%04d-%02d-%02d" src.year src.month src.day
  let of_string line =
    let tok_list = Str.split (Str.regexp "[-]") line in
    let int_list = List.map int_of_string tok_list in
    let at = List.nth int_list in
    init(at 0, at 1, at 2)
end

module Time = struct
  type t = { hour: int; minute: int; }
  let init (hour, minute) = { hour = hour; minute = minute; }
  let diff_in_minutes first second =
    60 * (first.hour - second.hour) + (first.minute - second.minute)
  let compare first second =
    let diff_hour = first.hour - second.hour in
    let diff_minute = first.minute - second.minute in
    if diff_hour != 0 then diff_hour else diff_minute
  let to_string src = sprintf "%02d:%02d" src.hour src.minute
  let of_string line =
    let tok_list = Str.split (Str.regexp "[:]") line in
    let int_list = List.map int_of_string tok_list in
    let at = List.nth int_list in
    init(at 0, at 1)
end

module Record = struct
  type action = Shift | Asleep | Wake
  type t = { id: int option; date: Date.t; time: Time.t; action: action }
  let compare first second =
    let diff_date = Date.compare first.date second.date in
    if diff_date != 0 then diff_date else Time.compare first.time second.time
  let init (id, date, time, action) = { id = id; date = date; time = time; action = action }
  let id src = src.id
  let action src = src.action
  let time src = src.time
  let assign_id src dst = init(src.id, dst.date, dst.time, dst.action)
  let of_string line =
    let record_regexp =
      (* PCRE: /\[(\d+) (\d+)\] (Guard.*|falls|wakes)/ *)
      Str.regexp "\\[\\([0-9-]+\\) \\([0-9:]+\\)\\] \\(Guard.*\\|falls\\|wakes\\)"
    in
    let action_of_string line =
      if String.equal line "falls asleep" then
        Asleep
      else if String.equal line "wakes up" then
        Wake
      else
        Shift
    in
    let id_of_string line =
      let int_regex = Str.regexp ".*#\\([0-9]+\\).*" in
      let int_string = Str.global_replace int_regex "\\1" line in
      try Some(int_of_string int_string) with _ -> None
    in
    let replaced = Str.global_replace record_regexp "\\1,\\2,\\3" line in
    let splitted = Str.split (Str.regexp ",") replaced in
    let at = List.nth splitted in
    let date = Date.of_string (at 0) in
    let time = Time.of_string (at 1) in
    let action = action_of_string (at 2) in
    let id = id_of_string (at 2) in
    init (id, date, time, action)
  let to_string src =
    let date_string = Date.to_string src.date in
    let time_string = Time.to_string src.time in
    let prefix = sprintf "[%s %s]" date_string time_string in
    match (src.id, src.action) with
    | Some id, Asleep -> sprintf "%s Guard #%d falls asleep" prefix id
    | Some id, Wake -> sprintf "%s Guard #%d wakes up" prefix id
    | Some id, Shift -> sprintf "%s Guard #%d begins shift" prefix id
    | None, Asleep -> sprintf "%s falls asleep" prefix
    | None, Wake -> sprintf "%s wakes up" prefix
    | _ -> "Should never happen"
end

let records = List.map (Record.of_string) lines
;;
let sorted_records = List.fast_sort (Record.compare) records
;;

module IntMap = Map.Make(Int)

type guard = {
  id: int;
  sleep: int; (* in minutes *)
  time_ranges: (Time.t * Time.t) list;
}

let guard_map =
  let guard_mapping = ref IntMap.empty in
  let last_id = ref 0 in
  let last_sleep_time = ref (Time.init(0, 0)) in
  List.iter (fun r ->
    match Record.id r with
    | Some id -> last_id := id;
    | None ->
      match Record.action r with
      | Shift -> ();
      | Asleep -> last_sleep_time := Record.time r;
      | Wake ->
        let diff_sleep = Time.diff_in_minutes (Record.time r) (!last_sleep_time) in
        let time_range = (!last_sleep_time, r.time) in
        guard_mapping := IntMap.update (!last_id) (fun found_opt ->
          match found_opt with
          | Some found -> Some({
              id = found.id;
              sleep = found.sleep + diff_sleep;
              time_ranges = found.time_ranges @ [time_range]
            })
          | None -> Some({ id = !last_id; sleep = diff_sleep; time_ranges = [time_range] })
        ) !guard_mapping
  ) sorted_records;
  !guard_mapping
;;

let guards = List.map (fun (_, guard) -> guard) (IntMap.bindings guard_map)
;;

let answer1 =
  let lazist_guard =
    List.fold_left(fun lazist_guard guard ->
      if guard.sleep > lazist_guard.sleep then guard else lazist_guard
    ) (List.hd guards) (List.tl guards)
  in
  let minute_histogram =
    List.fold_left (fun histo (s, e) ->
      let minutes = List.init (Time.diff_in_minutes e s) (Int.add s.minute) in
      List.fold_left (fun hist m ->
        IntMap.update m (fun count ->
          match count with Some c -> Some(c + 1) | None -> Some(1)
        ) hist
      ) histo minutes
    ) IntMap.empty (lazist_guard.time_ranges)
  in
  let (max_freq_minute, _) =
    List.fold_left (fun (prev_minute, prev_count) (minute, count) ->
      if count > prev_count then (minute, count) else (prev_minute, prev_count)
    ) (0, 0) (IntMap.bindings minute_histogram)
  in
  (lazist_guard.id * max_freq_minute)
;;

let () = printf "answer 1: %d\n" answer1
;;
