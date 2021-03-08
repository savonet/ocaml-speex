ocaml-speex
===========

This package contains an OCaml interface for the `speex` library

Please read the COPYING file before using this software.

Prerequisites:
==============

- ocaml
- libspeex
- findlib
- ocaml-ogg >= 0.7.0
- dune >= 2.0

Compilation:
============

```
$ dune build
```

This should build both the native and the byte-code version of the
extension library.

Installation:
=============

Via `opam`:

```
$ opam install speex
```

Via `dune` (for developers):
```
$ dune install
```

This should install the library file in the appropriate place.
