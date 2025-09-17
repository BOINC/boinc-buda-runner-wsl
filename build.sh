#!/bin/sh

# This file is part of BOINC.
# https://boinc.berkeley.edu
# Copyright (C) 2025 University of California
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

set -e

arch=$1

url="https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/${arch}/alpine-minirootfs-3.22.1-${arch}.tar.gz"

curl -L $url -o alpine.tar.gz
mkdir -p alpine
tar -xzf alpine.tar.gz -C alpine --strip-components=1
rm alpine.tar.gz

cp ./oobe.sh ./alpine/etc/
cp ./wsl-distribution.conf ./alpine/etc/
cp ./wsl.conf ./alpine/etc/
mkdir -p ./alpine/usr/lib/wsl
cp ./boinc.ico ./alpine/usr/lib/wsl/
cp ./terminal-profile.json ./alpine/usr/lib/wsl/

cd alpine
tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
cd ..
rm -rf alpine
mv install.tar.gz boinc-buda-runner-${arch}.wsl
