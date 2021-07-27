type t =
  { last_updated : string
  ; repository_urls : string list
  }

val t_of_yojson : Yojson.Safe.t -> t

val yojson_of_t : t -> Yojson.Safe.t
