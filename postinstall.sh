#!/bin/bash

export PREFIX="$PWD/install"

_do () {
  set -u
  set -e
  set -o pipefail

  ./configure --no-native-compiler --no-ocamldoc --no-debugger --no-graph --prefix "$PREFIX"

  make -j -C byterun
  cp byterun/ocamlrun boot/ocamlrun
	make -j -C stdlib \
	  COMPILER="../boot/ocamlc -use-prims ../byterun/primitives" all
  (cd stdlib; cp stdlib.cma std_exit.cmo ./*.cmi camlheader ../boot);
  (cd boot; ln -s ../byterun/libcamlrun.a .);

  make -j utils/config.cmo
  make -j utils/misc.cmo
  make -j -C tools ocamlmklib

  make -j -C otherlibs/unix libunix.a
  make -j -C otherlibs/systhreads libthreads.a

  mkdir -p "$PREFIX/lib/ocaml" "$PREFIX/bin"
  echo "$PREFIX/lib/ocaml" > "$PREFIX/lib/ocaml/ld.conf"
  cp byterun/ocamlrun "$PREFIX/bin"
  cp otherlibs/unix/dllunix.so "$PREFIX/lib/ocaml"
  cp otherlibs/systhreads/dllthreads.so "$PREFIX/lib/ocaml"
  chmod +x "$PREFIX/bin/ocamlrun"
}
export -f _do

_test () {
  ("$PREFIX/bin/ocamlrun" ./test > /dev/null)
  return $?
}
export -f _test

# check if we already have ocamlrun built
# some package managers (yarn) build the same package multiple times so this is
# why we do this check
if  _test; then
  exit 0
fi

tar -xzf ocaml.tar.gz

LOG=$(cd ocaml && _do)
if [ $? -ne 0 ]; then
  echo "$LOG"
  exit 1
fi

if ! _test; then
  echo "error: ocamlrun wasn't built correctly, unable to execute test file"
  exit 1
fi
