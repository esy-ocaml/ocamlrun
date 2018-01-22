# @esy-ocaml/ocamlrun

This repository contains an npm package which wraps the bytecode VM portion of
the OCaml toolchain as an npm package.

The idea is to be able to distribute bytecode compiled OCaml programs on npm and
have them executed using this package.

The goal is also to have a very quick installation, current on MacBook Pro 2016
it takes around 18s to compile the `ocamlrun`.

## Usage

```
% npm install -g @esy-ocaml/ocamlrun
% ocamlrun ./my-bytecode-compiled-executable
```

## TODO

- [ ] CI
- [ ] Figure out how to handle `Unix` module in a portable way
