val get_all_results :
     start:CalendarLib.Date.t
  -> finish:CalendarLib.Date.t
  -> token:Github.Token.t
  -> (CalendarLib.Date.t * Github_t.repository list) Lwt.t
