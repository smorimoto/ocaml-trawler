module Contents : sig
  val exists : owner:string -> name:string -> path:string -> bool Lwt.t
end
