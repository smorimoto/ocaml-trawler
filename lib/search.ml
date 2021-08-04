open Base
open Lwt.Syntax

let rec get_all_results ~start ~finish ~token =
  let* results =
    Github.Search.repos ~token
      ~qualifiers:
        [ `Language "OCaml"
        ; `Created
            (`Range
              ( Some (CalendarLib.Printer.Date.to_string start)
              , Some (CalendarLib.Printer.Date.to_string finish) ))
        ]
      ~keywords:[] ()
    |> Github.Stream.to_list |> Github.Monad.run
  in
  let* repository_search_total_count =
    match List.hd results with
    | Some hd -> Lwt.return hd.repository_search_total_count
    | None -> failwith "Repository_search_total_count not found"
  in
  let diff = CalendarLib.Date.sub finish start in
  if repository_search_total_count > 1000 then
    let new_finish =
      let days = CalendarLib.Date.Period.nb_days diff / 2 in
      CalendarLib.Date.add start (CalendarLib.Date.Period.day days)
    in
    get_all_results ~start ~finish:new_finish ~token
  else if
    let today = CalendarLib.Date.today () in
    let open Float in
    CalendarLib.Date.to_unixfloat finish > CalendarLib.Date.to_unixfloat today
  then
    let diff =
      if repository_search_total_count < 500 then
        CalendarLib.Date.Period.(nb_days diff * 2 |> day)
      else
        diff
    in
    let start = CalendarLib.Date.add finish (CalendarLib.Date.Period.day 1) in
    let finish = CalendarLib.Date.add finish diff in
    get_all_results ~start ~finish ~token
  else
    let list =
      List.concat_map results ~f:(fun res -> res.repository_search_items)
    in
    Lwt.return (finish, list)
