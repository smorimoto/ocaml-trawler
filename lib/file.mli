val read_dataset : Fpath.t -> (Dataset.t, unit) result Lwt.t

val write_dataset :
  path:Fpath.t -> content:Dataset.t -> (unit, unit) result Lwt.t
