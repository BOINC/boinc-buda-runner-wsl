#!/bin/sh

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
