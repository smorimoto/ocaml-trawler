open Base
open Trawler
open Lwt.Syntax

let path =
  let project_root = Rresult.R.get_ok (Bos.OS.Dir.current ()) in
  let json_path = Fpath.v "dataset/data.json" in
  Fpath.(project_root // json_path)

let search () =
  let* json = File.read_dataset path in
  let start =
    match json with
    | Ok { updated_at; _ } -> CalendarLib.Printer.Date.from_string updated_at
    | Error _ -> CalendarLib.Date.(make 2008 3 1)
  in
  let finish = CalendarLib.Date.today () in
  let token =
    try Github.Token.of_string (Unix.getenv "GITHUB_TOKEN") with
    | _ -> failwith "GITHUB_TOKEN not found"
  in
  let* finish, list = Search.get_all_results ~start ~finish ~token in
  let* repository_list =
    Lwt_list.map_s
      (fun ({ repository_owner = { user_login = owner; _ }
            ; repository_name = name
            ; repository_fork = fork
            ; repository_clone_url = clone_url
            ; repository_default_branch = default_branch
            ; repository_created_at = created_at
            ; repository_updated_at = updated_at
            ; _
            } :
             Github_t.repository) ->
        let* github_actions =
          Repo.Contents.exists ~owner ~name ~path:".github/workflows"
        in
        Lwt.return
          (Dataset.make_repository ~owner ~name ~fork ~clone_url ?default_branch
             ~created_at ~updated_at ~github_actions ()))
      list
  in
  let new_repository_list =
    let previous_repository_list =
      match json with
      | Ok { repository_list; _ } -> repository_list
      | Error _ -> []
    in
    List.append previous_repository_list repository_list
  in
  let finish = CalendarLib.Printer.Date.to_string finish in
  if List.length repository_list > 0 then
    Lwt.return_some
      (Dataset.make ~updated_at:finish ~repository_list:new_repository_list ())
  else
    Lwt.return_none

let rec main () =
  let* dataset = search () in
  match dataset with
  | Some dataset -> (
    let* res = File.write_dataset ~path ~content:dataset in
    match res with
    | Ok _ -> main ()
    | Error _ -> failwith "could not write dataset")
  | None -> Lwt.return_unit

let () = Lwt_main.run (main ())
