open Base
open Trawler
open Lwt.Syntax

let read_dataset file =
  Lwt.catch
    (fun _ ->
      let* channel = Lwt_io.open_file ~mode:Lwt_io.Input file in
      let* content = Lwt_io.read channel in
      let* () = Lwt_io.close channel in
      let dataset = Dataset.t_of_yojson (Yojson.Safe.from_string content) in
      Lwt.return_some dataset)
    (fun _ -> Lwt.return_none)

let main =
  let project_root = Rresult.R.get_ok (Bos.OS.Dir.current ()) in
  let dataset_json =
    let json_path = Fpath.v "dataset/data.json" in
    Fpath.(project_root // json_path)
  in
  let* json = read_dataset (Fpath.to_string dataset_json) in
  let start =
    match json with
    | Some { last_updated; _ } ->
      CalendarLib.Printer.Date.from_string last_updated
    | None -> CalendarLib.Date.(make 2008 3 1)
  in
  let finish = CalendarLib.Date.today () in
  let token =
    try Github.Token.of_string (Unix.getenv "GITHUB_TOKEN") with
    | _ -> raise_s (Sexp.List [ Sexp.Atom "GITHUB_TOKEN not found" ])
  in
  let* finish, list = Search.get_all_results ~start ~finish ~token in
  let repository_urls =
    List.map list ~f:(fun repo -> repo.repository_clone_url)
  in
  let new_repository_urls =
    let previous_repository_urls =
      match json with
      | Some { repository_urls; _ } -> repository_urls
      | None -> []
    in
    List.append previous_repository_urls repository_urls
  in
  let finish = CalendarLib.Printer.Date.to_string finish in
  Dataset.yojson_of_t
    { last_updated = finish; repository_urls = new_repository_urls }
  |> Yojson.Safe.to_string |> Stdlib.print_endline |> Lwt.return

let () = Lwt_main.run main
