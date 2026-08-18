#!/bin/sh

# This file is part of BOINC.
# https://boinc.berkeley.edu
# Copyright (C) 2026 University of California
#
# BOINC is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# BOINC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with BOINC.  If not, see <http://www.gnu.org/licenses/>.

# This script is heavily based on the https://salsa.debian.org/debian/WSL/-/raw/master/create-targz.sh script, which is licensed under the MIT License.

set -e

BUILDIR=$(pwd)
ROOTFSDIR="$BUILDIR/rootfs"
mkdir -p "$ROOTFSDIR"
TMPDIR_X64=$(mktemp -d -p "$ROOTFSDIR")
TMPDIR_ARM64=$(mktemp -d -p "$ROOTFSDIR")

DIST="trixie"

cleanup() {
    rm -rf "$ROOTFSDIR"
}
trap cleanup EXIT

create_rootfs() {
    local target_arch="$1"
    local debian_arch tmpdir

    case "$target_arch" in
        x86_64)
            debian_arch="amd64"
            tmpdir="$TMPDIR_X64"
            ;;
        aarch64)
            debian_arch="arm64"
            tmpdir="$TMPDIR_ARM64"
            ;;
        *)
            echo "Unknown architecture: $target_arch" >&2
            return 1
            ;;
    esac

    cd "$tmpdir"

    mmdebstrap --arch "$debian_arch" --include=sudo,locales,libpam-systemd,dbus,ca-certificates "$DIST" "$DIST" "$BUILDIR/debian.sources"
    chroot "$DIST" apt-get clean
    chroot "$DIST" /bin/bash -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen"
    chroot "$DIST" /bin/bash -c "update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8"
    cp "$BUILDIR/wsl-distribution.conf" "$tmpdir/$DIST/etc/wsl-distribution.conf"
    cp "$BUILDIR/wsl.conf" "$tmpdir/$DIST/etc/wsl.conf"
    mkdir -p "$tmpdir/$DIST/usr/lib/wsl/"
    cp "$BUILDIR/oobe.sh" "$tmpdir/$DIST/etc/oobe.sh"
    chmod 755 "$tmpdir/$DIST/etc/oobe.sh"
    cp "$BUILDIR/boinc.ico" "$tmpdir/$DIST/usr/lib/wsl/boinc.ico"
    cp "$BUILDIR/terminal-profile.json" "$tmpdir/$DIST/usr/lib/wsl/"
    mkdir -p "$tmpdir/$DIST/etc/containers"
    cp "$BUILDIR/containers.conf" "$tmpdir/$DIST/etc/containers/containers.conf"
    rm -f "$tmpdir/$DIST/etc/resolv.conf"

    cd "$DIST"
    tar --numeric-owner --absolute-names -c  * | gzip --best > "$tmpdir/install.tar.gz"
    mv -f "$tmpdir/install.tar.gz" "$BUILDIR/boinc-buda-runner-${target_arch}.wsl"
}

case "$1" in
    x86_64)
        create_rootfs "x86_64"
        ;;
    aarch64)
        create_rootfs "aarch64"
        ;;
    *)
        echo "Usage: $0 [x86_64|aarch64]" >&2
        exit 1
        ;;
esac
