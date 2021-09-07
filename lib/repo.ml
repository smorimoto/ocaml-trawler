open Base
open Lwt.Syntax

module Contents = struct
  let exists ~owner ~name ~path =
    let open Cohttp in
    let open Cohttp_lwt_unix in
    let headers =
      let init = Header.init () in
      let header = Header.add init "Accept" "application/vnd.github.v3+json" in
      let value =
        let token =
          try Unix.getenv "GITHUB_TOKEN" with
          | _ -> failwith "GITHUB_TOKEN not found"
        in
        Caml.Format.sprintf "token %s" token
      in
      Header.add header "Authorization" value
    in
    let path =
      String.concat [ "repos"; owner; name; "contents"; path ] ~sep:"/"
    in
    let uri = Uri.make ~scheme:"https" ~host:"api.github.com" ~path () in
    let* { status; _ }, body = Client.get uri ~headers in
    let* () = Cohttp_lwt.Body.drain_body body in
    match status with
    | `OK -> Lwt.return_true
    | _ -> Lwt.return_false
end
