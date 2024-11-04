#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


# https://github.com/blue-build/modules/blob/bc0cfd7381680dc8d4c60f551980c517abd7b71f/modules/rpm-ostree/rpm-ostree.sh#L16
echo "Creating symlinks to fix packages that install to /opt"
# Create symlink for /opt to /var/opt since it is not created in the image yet
mkdir -p "/var/opt"
ln -s "/var/opt"  "/opt"

# intel-lpmd
# https://packages.fedoraproject.org/pkgs/intel-lpmd/intel-lpmd/

rpm-ostree install https://kojipkgs.fedoraproject.org//packages/intel-lpmd/0.0.8/1.fc42/x86_64/intel-lpmd-0.0.8-1.fc42.x86_64.rpm

# sudo systemctl start intel_lpmd.service

# Remove tuned-ppd to prevent GNOME touching tuned
# https://github.com/ublue-os/bluefin/issues/1824#issuecomment-2436177630
rpm-ostree override remove tuned-ppd

# Add cloudflare-warp.repo to /etc/yum.repos.d/
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo

# Add xlion-rustdesk-rpm-repo.repo to /etc/yum.repos.d/
curl -fsSl https://rustdesk-rpm-repo.xlion.dev/nightly_r2.repo | tee /etc/yum.repos.d/xlion-rustdesk-rpm-repo.repo

# Install
rpm-ostree install cloudflare-warp screen tuned waydroid ntpd-rs sudo-rs rustdesk libwebp-tools wireshark

#rpm-ostree install https://github.com/Open-Wine-Components/umu-launcher/releases/download/1.1.1/umu-launcher-1.1.1-1.20241004.12ebba1.fc40.noarch.rpm

#### Example for enabling a System Unit File

systemctl enable warp-svc.service
systemctl enable rustdesk.service
systemctl enable zerotier-one

## Use ntpd-rs to replace chronyd
systemctl disable chronyd
systemctl enable ntpd-rs
