(lang dune 2.8)
(version 0.4.2)
(name speex)
(source (github savonet/ocaml-speex))
(license GPL-2.0)
(authors "The Savonet Team <savonet-users@lists.sourceforge.net>")
(maintainers "The Savonet Team <savonet-users@lists.sourceforge.net>")

(generate_opam_files true)
(use_standard_c_and_cxx_flags false)

(package
 (name speex)
 (synopsis "Bindings to libspeex")
 (depends
  conf-libogg
  conf-libspeex
  conf-pkg-config
  dune
  dune-configurator
  (ocaml (>= 4.07))
  (ogg (>= 0.7.0)))
)
