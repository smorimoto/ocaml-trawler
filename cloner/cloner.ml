open Base
open Trawler
open Lwt.Syntax

let exec ?cwd ?env ?stdin ?stdout ?stderr argv =
  let* process_status =
    Lwt_process.exec ?cwd ?env ?stdin ?stdout ?stderr ("", argv)
  in
  match process_status with
  | Unix.WEXITED 0 -> Lwt.return_unit
  | Unix.WEXITED n ->
    failwith (Caml.Format.sprintf "exec failed with exit code %i" n)
  | _ -> failwith "exec failed"

let clone ~clone_url ~clone_path =
  exec [| "git"; "clone"; clone_url; clone_path |]

let pull cwd = exec ~cwd [| "git"; "pull" |]

let cloner ~owner ~name ~clone_url =
  let project_root = Rresult.R.get_ok (Bos.OS.Dir.current ()) in
  let clone_path = Fpath.(project_root // v "repo" / owner / name) in
  match Bos.OS.Path.exists clone_path with
  | Ok true -> pull (Fpath.to_string clone_path)
  | Ok false -> clone ~clone_url ~clone_path:(Fpath.to_string clone_path)
  | _ ->
    failwith
      (Caml.Format.sprintf "cloner failed with path %s"
         (Fpath.to_string clone_path))

let main =
  let path =
    let project_root = Rresult.R.get_ok (Bos.OS.Dir.current ()) in
    let json_path = Fpath.v "dataset/data.json" in
    Fpath.(project_root // json_path)
  in
  let* json = File.read_dataset path in
  let repository_list =
    match json with
    | Ok { repository_list; _ } -> repository_list
    | Error _ -> failwith "read_dataset failed"
  in
  Lwt_list.iter_s
    (fun ({ owner; name; clone_url; _ } : Dataset.repository) ->
      cloner ~owner ~name ~clone_url)
    repository_list

let () = Lwt_main.run @@ main
