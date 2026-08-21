#!/usr/bin/env bash

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

set -ue

DEFAULT_UID='1000'
DEFAULT_USER='boinc'

echo "Creating default user account '$DEFAULT_USER'..."
/usr/sbin/useradd -m -u "$DEFAULT_UID" -c '' -s /bin/sh "$DEFAULT_USER"
echo "User account '$DEFAULT_USER' created"

echo "Updating package index..."
apt update
echo "Package index updated"

echo "Setting up certificates..."
apt install -y ca-certificates
update-ca-certificates
echo "Certificates setup complete"

echo "Fixing permissions..."
chmod 1777 /var/tmp
echo "Permissions fixed"

echo "Setting version..."
echo "version: 6" > /home/$DEFAULT_USER/version.txt
chown $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/version.txt
echo "Version set"

GPUS_JSON=/home/${DEFAULT_USER}/gpus.json

if [ -f /usr/lib/wsl/lib/libcuda.so ]; then
    echo "Setting up NVIDIA Container Toolkit..."
    apt install -y gnupg2 curl
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt update
    apt install -y nvidia-container-toolkit
    systemctl enable --now nvidia-cdi-refresh.path
    systemctl enable --now nvidia-cdi-refresh.service
    nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml

    found=0
    json="{\"gpus\":["
    CUDA_TXT=/var/tmp/cuda.txt
    /usr/lib/wsl/lib/nvidia-smi -L > ${CUDA_TXT}
    echo "CUDA GPU(s) detected:"
    while read -r line; do
        if [[ "$line" =~ ^GPU[[:space:]]+([0-9]+):[[:space:]]*(.*)[[:space:]]+\(UUID: ]]; then
            gpu_number="${BASH_REMATCH[1]}"
            gpu_name="${BASH_REMATCH[2]}"
            if [ "x$gpu_number" != "x" ] && [ "x$gpu_name" != "x" ]; then
                echo "$gpu_number: $gpu_name"
                if [ $found -eq 1 ]; then
                    json="$json,"
                fi
                json="$json{\"name\":\"nvidia\",\"has_cuda\":true,\"has_opencl\":false,\"gpu_name\":\"$gpu_name\",\"cuda_number\":$gpu_number,\"opencl_number\":null}"
                found=1
            fi
        fi
    done < ${CUDA_TXT}
    rm -f ${CUDA_TXT}
    json="$json]}"
    if [ $found -eq 1 ]; then
        echo $json > ${GPUS_JSON}
    fi
    echo "NVIDIA Container Toolkit setup complete"
else
    echo "No CUDA GPU detected"
fi

if [ -f ${GPUS_JSON} ]; then
    chown $DEFAULT_USER:$DEFAULT_USER ${GPUS_JSON}
fi

echo "Setting up podman..."
apt install -y podman iptables
echo $DEFAULT_USER:100000:65536 >/etc/subuid
echo $DEFAULT_USER:100000:65536 >/etc/subgid
echo "Podman setup complete"
