#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


# https://github.com/blue-build/modules/blob/bc0cfd7381680dc8d4c60f551980c517abd7b71f/modules/rpm-ostree/rpm-ostree.sh#L16
echo "Creating multiple symlinks that didn't created in the image yet"
# Create symlink for /opt to /var/opt since it is not created in the image yet
mkdir -p "/var/opt" && ln -s "/var/opt"  "/opt"
#mkdir -p "/var/usrlocal" && ln -s "/var/usrlocal" "/usr/local"


# Remove tuned-ppd to prevent GNOME touching tuned
# https://github.com/ublue-os/bluefin/issues/1824#issuecomment-2436177630
dnf5 -y remove tuned-ppd

# Add cloudflare-warp.repo to /etc/yum.repos.d/
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo

# Add xlion-rustdesk-rpm-repo.repo to /etc/yum.repos.d/
curl -fsSl https://xlionjuan.github.io/rustdesk-rpm-repo/nightly.repo | tee /etc/yum.repos.d/xlion-rustdesk-rpm-repo.repo

dnf5 upgrade -y dnf5

# Install
dnf5 install -y cloudflare-warp zerotier-one screen tuned waydroid ntpd-rs sudo-rs libwebp-tools wireshark koji rclone

#semanage fcontext -a -t bin_t "/usr/lib/rustdesk/rustdesk"
#restorecon -v "/usr/lib/rustdesk/rustdesk"

#dnf5 install -y https://github.com/21pages/rustdesk/releases/download/revert_linux_use_cpal_build/rustdesk-1.3.5-0.x86_64.rpm

# Make chsh back
#dnf5 reinstall -y util-linux

# intel-lpmd
# https://packages.fedoraproject.org/pkgs/intel-lpmd/intel-lpmd/

#dnf5 install -y https://kojipkgs.fedoraproject.org//packages/intel-lpmd/0.0.8/1.fc42/x86_64/intel-lpmd-0.0.8-1.fc42.x86_64.rpm

# sudo systemctl start intel_lpmd.service

#rpm-ostree install https://github.com/Open-Wine-Components/umu-launcher/releases/download/1.1.1/umu-launcher-1.1.1-1.20241004.12ebba1.fc40.noarch.rpm

#### Example for enabling a System Unit File

systemctl enable warp-svc.service
#systemctl enable rustdesk.service
systemctl enable zerotier-one

## Use ntpd-rs to replace chronyd
systemctl disable chronyd
systemctl enable ntpd-rs

# CachyOS Kernel
dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra zram-generator-defaults
dnf5 copr enable -y bieszczaders/kernel-cachyos-lto
dnf5 copr enable -y bieszczaders/kernel-cachyos-addons
rpm-ostree install kernel-cachyos-lto
dnf5 -y install scx-scheds cachyos-settings uksmd
systemctl enable scx.service
systemctl enable uksmd.service
