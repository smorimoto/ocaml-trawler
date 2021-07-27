.PHONY: build
build:
	dune build @all

.PHONY: update
update:
	dune build @update

.PHONY: promote
promote:
	dune promote
