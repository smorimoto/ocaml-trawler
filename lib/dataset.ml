open Base

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
[@@deriving make, yojson]

type t =
  { updated_at : string
  ; repository_list : repository list
  }
[@@deriving make, yojson]
