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

set -ue

DEFAULT_UID='1000'
DEFAULT_USER='boinc'

echo "Creating default user account '$DEFAULT_USER'..."
if getent passwd "$DEFAULT_UID" > /dev/null ; then
  echo "User account '$DEFAULT_USER' already exists, skipping creation"
  exit 0
fi
/usr/sbin/adduser -D --uid "$DEFAULT_UID" --gecos '' "$DEFAULT_USER"
echo "User account '$DEFAULT_USER' created"

echo "Setting up certificates..."
apk add --no-cache ca-certificates
update-ca-certificates
echo "Certificates setup complete"

echo "Fixing cgroups..."
apk add --no-cache openrc
sed -i 's/^#rc_cgroup_mode="unified"/rc_cgroup_mode="unified"/' /etc/rc.conf
rc-update add cgroups
echo "cgroups fixed"

echo "Fixing permissions..."
chmod 1777 /var/tmp
echo "Permissions fixed"

echo "Setting version..."
echo "version: 3" > /home/$DEFAULT_USER/version.txt
chown $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/version.txt
echo "Version set"

echo "Setting up podman..."
apk add --no-cache podman
modprobe tun
echo tun >>/etc/modules
echo $DEFAULT_USER:100000:65536 >/etc/subuid
echo $DEFAULT_USER:100000:65536 >/etc/subgid
echo "Podman setup complete"
