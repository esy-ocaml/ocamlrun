#!/bin/bash

export PREFIX="$PWD/install"

_do () {
  set -u
  set -e
  set -o pipefail

  createOCamlrunWrapper () {
    local filename="$PREFIX/bin/$2"
    printf "#!/bin/bash\\n" > "$filename"
    printf "export OCAMLLIB='%s/lib/ocaml'\\n" "$PREFIX" >> "$filename"
    printf '%s/bin/ocamlrun %s/bin/%s "$@"' "$PREFIX" "$PREFIX" "$1" >> "$filename"
    chmod +x "$PREFIX/bin/$2"
  }

  ./configure --no-native-compiler --no-ocamldoc --no-debugger --no-graph --prefix "$PREFIX"
  make -j world
  make -j install
  createOCamlrunWrapper "jbuilder.bc" "jbuilder"
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
if  _test > /dev/null 2>&1; then
  exit 0
fi

LOG=$(cd ocaml && _do)
if [ $? -ne 0 ]; then
  echo "$LOG"
  exit 1
fi

if ! _test; then
  echo "error: ocamlrun wasn't built correctly, unable to execute test file"
  exit 1
fi
