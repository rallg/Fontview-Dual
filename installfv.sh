#!/bin/sh
# Installation file 'installfv.sh' for 'Fontview Dual'.

# On Linux systems, you will need superuser permission to install.
# On Termux, you already have the necessary permissions.

# This script will build and install two small font viewer programs,
# named fontviewA and fontviewB. It will also install a BASH script
# named fontview-dual, which manages the other two.
# And, it installs a desktop file, for use with application Menu.
# The programs are small. If you have the build system and dependencies,
# it finishes in less than a minute.

# Rationale for the size class:
# Most software was historically developed at a time when screens were
# expected to have about 96pdi density. Unfortunately, the density was
# hard-coded into the software. Then, fonts and images appear too small,
# when viewed on modern HDPI screens with density 192 or more.
# On the other hand, recent software, and re-written older software,
# may recognize HDPI. Then the adjustment is automatic.
# A given system may have some software that adjusts, others not.
# So, this software does not know whether adjustment is needed.
# It guesses that you have HDPI screen at 192pdi, without system adjustment.
# That is the class 3 setting.
# If wrong guess, the other classes let you tweak it.

arg="$(echo $@ | sed 's/-*//g')"
export here="$PWD"

# Detect Termux or Linux. Test if sudo is needed for installation on Linux:
dosudo="no"
case "$here" in
	/data/data/com.termux*) t="yes" ;;
	*) t="no" ;;
esac

if [ "$t" = "no" ] ; then
	mkdir -p "/usr/local/bin" 2>/dev/null || dosudo="yes"
	mkdir -p "/usr/local/share/applications" 2>/dev/null || dosudo="yes"
	[ -w "/usr/local/bin" ] || dosudo="yes"
	[ -w "/usr/local/share/applications" ] || dosudo="yes"
fi
if [ "$dosudo" = "yes" ] ; then
	command -v sudo >/dev/null 2>&1
	[ "$?" -ne 0 ] && echo "Error. Program 'sudo' is not installed." && exit 2
fi

# Ensure that components are available:
linb="resource/meson.linux"
terb="resource/meson.termux"
sushi="resource/src/sushi-font-widget.c"
ok="yes"
[ "$t" = "no" ] && [ ! -f "$linb" ] && ok="no"
[ "$t" = "yes" ] && [ ! -f "$terb" ] && ok="no"
[ ! -f "$sushi" ] && ok="no"
if [ "$ok" = "no" ] ; then
	printf "\033[92mError.\033[0m Cannot find some fontview-dual files.\n"
	echo "Run ./installfv.sh from its own directory, not /path/to/installfv.sh."
	exit 3
fi

# Minimal check for compiler:
gotm="$(command -v meson 2>/dev/null)"
if [ -z "$gotm" ] ; then
	printf "\033[91mError.\033[0m Did not find meson compiler.\n"
	exit 2
fi

# Dialog:
echo "Displayed text will be scaled according to your screen density (dpi)."
echo "Some systems adjust for dpi. Others do not."
echo "This installer assumes you have an HPDI screen, not adjusted."
echo "If the installed program displays text too large or too small,"
echo "Then re-run this installer with another choice of size."
echo "Available sizes are 1 (small) to 5 (large). Default 3."
printf "\033[1mChoose a size [1|2|3|4|5|x] : \033[0m" ; read r
case "$r" in
	1) sed -i 's/.*fvsize.*/#include "fvsize-1.c"/' "$sushi" ;;
	2) sed -i 's/.*fvsize.*/#include "fvsize-2.c"/' "$sushi" ;;
	3) sed -i 's/.*fvsize.*/#include "fvsize-3.c"/' "$sushi" ;;
	4) sed -i 's/.*fvsize.*/#include "fvsize-4.c"/' "$sushi" ;;
	5) sed -i 's/.*fvsize.*/#include "fvsize-5.c"/' "$sushi" ;;
	x|X) echo "Exit at your request. Nothing done." && exit ;;
	*) sed -i 's/.*fvsize.*/#include "fvsize-3.c"/' "$sushi" ;;
esac

# Set prefix for Termux or Linux:
cd resource
if [ "$t" = "no" ] ; then
	cp meson.linux meson.build
else
	cp meson.termux meson.build
fi
rm -r -f build
mkdir -p build

# Further instructions:
if [ "$dosudo" = "yes" ] ; then
	echo "Ready. At install, you may be asked for your sudo password."
	echo "Now command:"
	echo "    cd resource/build"
	echo "    meson && meson compile && sudo meson install"
else
	echo "Ready. Now command:"
	echo "    cd resource/build"
	echo "    meson && meson compile && meson install"
fi
exit
##
