export PREFIX="$PWD/install"

_do () {
  set -u
  set -e
  set -o pipefail

  TARGET="_build/default/src/unix/dlllwt_unix_stubs.so"

  patch -p1 < ../lwt.patch
  PATH="$PREFIX/bin:$PATH" make check-config
  PATH="$PREFIX/bin:$PATH" ocamlrun "$PREFIX/bin/jbuilder.bc" build -p lwt "$TARGET"
  cp "$TARGET" "$PREFIX/lib/ocaml/stublibs"

}
export -f _do

LOG=$(cd lwt && _do 2>&1)
if [ $? -ne 0 ]; then
  echo "$LOG"
  exit 1
fi
