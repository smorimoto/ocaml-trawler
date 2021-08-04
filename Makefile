.PHONY: build
build:
	dune build @all

.PHONY: update
update:
	dune exec -- update
