type repository =
  { owner : string
  ; name : string
  ; fork : bool
  ; clone_url : string
  ; default_branch : string option
  ; created_at : string
  ; updated_at : string
  ; github_actions : bool
  }

val make_repository :
     owner:string
  -> name:string
  -> fork:bool
  -> clone_url:string
  -> ?default_branch:string
  -> created_at:string
  -> updated_at:string
  -> github_actions:bool
  -> unit
  -> repository

val repository_of_yojson : Yojson.Safe.t -> repository

val yojson_of_repository : repository -> Yojson.Safe.t

type t =
  { updated_at : string
  ; repository_list : repository list
  }

val make : updated_at:string -> ?repository_list:repository list -> unit -> t

val t_of_yojson : Yojson.Safe.t -> t

val yojson_of_t : t -> Yojson.Safe.t
