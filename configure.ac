
# check for one particular file of the sources 
AC_INIT(ocaml-speex, 0.1.2, savonet-users@lists.sourceforge.net)

VERSION=$PACKAGE_VERSION
AC_MSG_RESULT([configuring $PACKAGE_STRING])

# Add prefix to compilation variables
# if passed
if test "x$prefix" != "xNONE"; then
	CFLAGS="$CFLAGS -I$prefix/include"
	LDFLAGS="$LDFLAGS -L$prefix/lib"
	CPPFLAGS="$CPPFLAGS -I$prefix/include"
fi

AC_CHECK_OCAML_COMPILERS()

AC_PROG_CC()
AC_CHECK_TOOL([AR],[ar],no)
PKG_PROG_PKG_CONFIG()
#PKG_CHECK_MODULES(speex, speex, , [AC_MSG_ERROR(speex not found.)])

# PKG_CHECK_MODULES loses when you need --libs-only-[lL]
if ! $PKG_CONFIG --exists speex; then
        AC_MSG_ERROR([speex not found])
fi
speex_CFLAGS=`$PKG_CONFIG --cflags speex`
AC_SUBST([speex_CFLAGS])
speex_LIBS=`$PKG_CONFIG --libs-only-l speex`
AC_SUBST([speex_LIBS])
speex_LDFLAGS=`$PKG_CONFIG --libs-only-L speex`
AC_SUBST([speex_LDFLAGS])

if ! $PKG_CONFIG --exists ogg; then
        AC_MSG_ERROR([libogg not found.])
fi
ogg_LDFLAGS=`$PKG_CONFIG --libs-only-L ogg`
AC_SUBST([ogg_LDFLAGS])
ogg_CFLAGS=`$PKG_CONFIG --cflags ogg`
AC_SUBST([ogg_CFLAGS])
ogg_LIBS=`$PKG_CONFIG --libs-only-l ogg`
AC_SUBST([ogg_LIBS])

AC_ARG_WITH([ogg-dir],AC_HELP_STRING([--with-ogg-dir=path],
        [use "path" as the location of ocaml-ogg (autodetected by default)]))
if test -z "$with_ogg_dir"; then
  AC_MSG_CHECKING(for ocaml-ogg)
  if ($OCAMLFIND query ogg > /dev/null 2>&1); then
        OCAMLOGG_INC=`$OCAMLFIND query ogg`
        AC_MSG_RESULT(ok)
  else
        AC_MSG_ERROR(not found.)
  fi
else
  echo $with_ogg_dir | grep ^/ > /dev/null 2>&1 \
  || with_ogg_dir=$PWD/$with_ogg_dir
  OCAMLOGG_INC="$with_ogg_dir"
fi
AC_SUBST(OCAMLOGG_INC)

# substitutions to perform
AC_SUBST(VERSION)
AC_SUBST(INC)
AC_SUBST(requires)

# Finally create the Makefile and samples
AC_CONFIG_FILES([Makefile],[chmod a-w Makefile])
AC_CONFIG_FILES([src/META])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([examples/Makefile.speex2wav])
AC_CONFIG_FILES([examples/Makefile.wav2speex])
AC_OUTPUT
