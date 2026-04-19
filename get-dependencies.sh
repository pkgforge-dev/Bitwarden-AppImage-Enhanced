#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	libnotify  \
	libnss_nis \
	libxss     \
	libxtst

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	aarch64) farch=arm64;;
	x86_64)  farch=x64;;
esac
TARBALL_LINK=$(wget https://api.github.com/repos/bitwarden/clients/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*/bitwarden_.*${farch}.tar.gz")

wget --retry-connrefused --tries=30 "$TARBALL_LINK" -O /tmp/temp.tar.gz

mkdir -p ./AppDir/bin && (
	cd ./AppDir/bin
	tar -xvf /tmp/temp.tar.gz
	# bitwarden is a horirble script, remove it and just run the binary directly
	# https://github.com/bitwarden/clients/blob/641734fa3e93df0f74bcd21cdaf9ac5c56b17a1c/apps/desktop/resources/linux-wrapper.sh
	rm -f ./bitwarden
	ln -s ./bitwarden-app ./bitwarden
	
	cp -v ./resources/com.bitwarden.desktop.desktop ../
	cp -v ./resources/icons/256x256.png ../
	cp -v ./resources/icons/256x256.png ../.DirIcon
)

echo "$TARBALL_LINK" | awk -F'/' '{print $(NF-1)}' | awk -F'-' '{print $NF}' > ~/version
