#
# Makefile for the Lambda-eff-row calculus
#

# Build system: ocamlbuild
OBC=ocamlbuild
# bin-annot is required for Merlin and other IDE-like tools
OBC_FLAGS=-tag bin_annot -use-ocamlfind -Is common,parsing -cflag -safe-string
# Default compiler
CC=$(OBC) $(OBC_FLAGS)
# Custom toplevel compiler
TC=ocamlmktop

all: native byte

byte:
	$(CC) main.byte

native:
	$(CC) main.native

run-tests: tests
	./driver.native -list-test

tests: tests/driver.ml
	$(OBC) -Is common,parsing -use-ocamlfind -pkgs "oUnit,qcheck" tests/driver.native

clean:
	$(CC) -clean

.PHONY: all clean native tests
