(lang dune 2.9)

(name ocaml-trawler)

(implicit_transitive_deps true)

(generate_opam_files true)

(license ISC)

(authors "Sora Morimoto <sora@morimoto.io>")

(maintainers "Sora Morimoto <sora@morimoto.io>")

(source
 (github smorimoto/ocaml-trawler))

(bug_reports "https://github.com/smorimoto/ocaml-trawler/issues")

(homepage "https://github.com/smorimoto/ocaml-trawler")

(documentation "https://github.com/smorimoto/ocaml-trawler")

(package
 (name ocaml-trawler)
 (synopsis "Trawler")
 (description "Trawler")
 (depends
  base
  bos
  calendar
  conf-libev
  github
  github-unix
  lwt
  ppx_deriving
  ppx_yojson_conv
  tls
  yojson))
