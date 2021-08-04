open Base
open Lwt.Syntax

let read_file path =
  Lwt.catch
    (fun _ ->
      let* channel = Lwt_io.open_file ~mode:Lwt_io.Input path in
      let* content = Lwt_io.read channel in
      let* () = Lwt_io.close channel in
      Lwt.return_ok content)
    (fun _ -> Lwt.return_error ())

let write_file ~path ~content =
  Lwt.catch
    (fun _ ->
      let* channel = Lwt_io.open_file ~mode:Lwt_io.Output path in
      let* () = Lwt_io.write channel content in
      let* () = Lwt_io.close channel in
      Lwt.return_ok ())
    (fun _ -> Lwt.return_error ())

let read_dataset path =
  Lwt.catch
    (fun _ ->
      let* res = read_file (Fpath.to_string path) in
      match res with
      | Ok content ->
        let dataset = Dataset.t_of_yojson (Yojson.Safe.from_string content) in
        Lwt.return_ok dataset
      | Error _ -> Lwt.return_error ())
    (fun _ -> Lwt.return_error ())

let write_dataset ~path ~content =
  Lwt.catch
    (fun _ ->
      let path = Fpath.to_string path in
      let content =
        Yojson.Safe.pretty_to_string (Dataset.yojson_of_t content)
      in
      let* res = write_file ~path ~content in
      Lwt.return res)
    (fun _ -> Lwt.return_error ())
