#!/bin/bash

set -ouex pipefail

# >>>>>>>>>> Intel® oneAPI Toolkits
# https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/2024-2/yum-dnf-zypper.html#GUID-91D791FE-995A-48B1-B479-0B6AAEB91E8D

# Add Repo
tee > /etc/yum.repos.d/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

# Symlink
mkdir -p "/var/usrlocal"
ln -s "/var/usrlocal"  "/usr/local"
mkdir -p "/usr/local/share/pkgconfig"

# Install

# GG, seens ran out of runner's disk space
#rpm-ostree install intel-basekit

rpm-ostree install intel-oneapi-runtime-libs
