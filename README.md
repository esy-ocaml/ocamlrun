# @esy-ocaml/ocamlrun

This repository contains an npm package which wraps the bytecode VM portion of
the OCaml toolchain + a set of dynamically loaded libs as an npm package.

The idea is to be able to distribute bytecode compiled OCaml programs on npm and
have them executed using this package.

The goal is also to have a very quick installation, current on MacBook Pro 2016
it takes around 18s to compile the `ocamlrun`.

## Usage

```
% npm install -g @esy-ocaml/ocamlrun
% ocamlrun ./my-bytecode-compiled-executable
```

## Release

```
% make clean
% make dist
% npm publish
```

## How it works?

We compile `ocaml` and `jbuilder` into bytecode and distribute along with
`ocaml.tar.gz` and `lwt.tar.gz`. On target machine we unpack `ocaml.tar.gz` and
build the runtime portion (`ocamlrun` + needed C libs) then we build only C part
of `lwt` using bc-compiled `ocaml` and `jbuilder`. Finally we have an `ocamlrun`
exposed with a configured `$OCAMLLIB` which is able to run bytecompiled
executables which use lwt.

## TODO

- [ ] Support Windows
- [ ] CI
