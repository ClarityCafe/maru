#!/bin/bash
#
# Copyright 2018 (c) Capuccino <enra@sayonika.moe>
#
#
# Feel free to improve this script on GitHub

set -eo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
CHROOT_DIR="$BASE_DIR/chroot"
CHROMEOS_VERSION=

case "$1" in 
  amd64)
    BOARD_ARCH="amd64"
  ;;
  aarch64)
    echo "Warning: aarch64 builds are experimental. Build success is not guranteed."
    BOARD_ARCH="aarch64"
    sleep 2
  ;;
  --help | -h)
    echo "$0 <board_arch|--h(elp)> <cros_version>"
    echo ""
    echo "$0 builds the CrOS image from a maru overlay architecture defined in the first argument."
    echo "This script is created by Kibo Hikari, Licensed under MIT."
    exit 0;
   ;;
  *)
    echo "Invalid arch $1. Either its not supported yet or its not coded in $0 at the moment."
    echo "Run --help for more info."
    exit 1
  ;;
esac

if [ -z "$2" ]; then
  CHROMEOS_VERSION="release-R76-12239.B"
else
  CHROMEOS_VERSION="$2"
fi 

if [[ ! "$2" =~ ^release-R[0-9]{2}-[0-9]{5}\.B$ ]]; then 
   echo "$2 is not a valid ChromeOS version."
   exit 3;
fi


if [ "$(uname -m)" != "x86_64" ]; then
  echo "Error: Unsupported architecture. Most CrOS build tools were built for x86_64 machines."
  exit 1
fi

if [ -z "$(command -v proot)" ]; then
  echo "Error: proot is required to use this script!"
  exit 3
fi

if [ -z "$(command -v debootstrap)" ]; then
  echo "Error: debootstrap is required to use this script!"
  exit 3
fi

if [ -z "$(command -v git)" ]; then
  echo "Error: Git not found! You can't build Maru or Chromium OS from source without Git!"
  exit 3
fi

proot_exec() {
    proot -S "$CHROOT_DIR" -0 /usr/bin/env -i HOME=/root TERM="xterm-256color" PATH='PATH=/bin:/usr/bin:/sbin:/usr/sbin:/bin:/usr/local/repo' /bin/bash -c "$@" | while read -r line; do
     echo "[CHROOT] $line"
    done
}

echo "Welcome to $0! This script builds maru using proot and debootstrap"
echo "Make sure you set your git credentials accordingly. Happy coding!"

sleep 5

if [ -z "$(command -v repo)" ]; then
  echo "repo not installed. Installing from Google Sources..."
  sleep 2
  sudo mkdir -p /usr/local/repo
  sudo chmod -R 777 /usr/local/repo
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /usr/local/repo/depot_tools
  export PATH="/usr/local/repo/depot_tools:$PATH"
  echo 'export PATH=/usr/local/repo/depot_tools:$PATH' >> "$HOME/.profile";
else
   echo "repo found in path. Nothing to do in the host side :)"
   sleep 2
fi

echo "Setting up environment. Please be patient."
sleep 2

if [ ! -d "$CHROOT_DIR" ]; then
  mkdir "$CHROOT_DIR"
  # TODO: Figure out the non-PH mirror link to Ubuntu sources.
  sudo debootstrap --arch amd64 xenial "$CHROOT_DIR" http://mirror.rise.ph/ubuntu/
  sudo cp -vRf /usr/local/repo "$CHROOT_DIR/usr/local/"
  # Fix permissions so proot can get permissions to use the thing with extreme prejudice
  sudo chown -R 1000:1000 "$CHROOT_DIR"
  proot_exec apt-get -y install git-core gitk git-gui subversion curl lvm2 thin-provisioning-tools python-pkg-resources python-virtualenv python-oauth2client
else
  echo "$CHROOT_DIR is already setup. Nothing left to do."
fi

echo "Chroot setup done. Mounting directory."

mkdir "$CHROOT_DIR/mnt/cros"

sudo mount --bind "$BASE_DIR" "$CHROOT_DIR/mnt/cros"

echo "Initial Setup done, now building ChromiumOS."


proot_exec git config --global user.name "UbuntuChroot"
proot_exec git config --global user.email "noreply@github.com"
proot_exec git config --global color.ui true

proot_exec cd /mnt/cros && mkdir build && \
  cd build && \
  repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git -b "$CHROMEOS_VERSION" && \
  repo sync -j 100

proot_exec cd /mnt/cros && cp -vRf overlay-* build/src/overlays/

proot_exec cd /mnt/cros/build && cros_sdk --download -- setup_board --board=maru-"$BOARD_ARCH";
proot_exec cd /mnt/cros/build && cros_sdk -- ./build_packages --nowithdebug --board=maru-"$BOARD_ARCH";
proot_exec cd /mnt/cros/build && cros_sdk -- ./build_image --board=maru-"$BOARD_ARCH" base;

echo "Image has been built. Check $BASE_DIR/src/images/maru-$1."
exit 0
