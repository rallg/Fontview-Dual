#!/bin/sh
# For Linux.

ddir="$(grep -m 1 datadir ../meson.build 2>/dev/null)"
if [ -z "$ddir" ] ; then
	here="/usr/local/share/applications"
else
	here="$(echo $ddir | sed 's/\x27//g')"
	here="$(echo $here | sed 's/datadir//')"
	here="$(echo $here | sed 's/=//' | sed 's/\s*//g')"
fi

cp ../src/fontview-dual "$MESON_INSTALL_PREFIX/bin"
chmod 755 "$MESON_INSTALL_PREFIX/bin/fontview-dual"
mkdir -p "$here"
cp ../src/fontview-dual.desktop "$here/"

exit
##
