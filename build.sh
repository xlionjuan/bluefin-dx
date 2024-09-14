#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1



# Create symlinks to fix packages that create directories in /opt
get_yaml_array OPTFIX '.optfix[]' "$1"
if [[ ${#OPTFIX[@]} -gt 0 ]]; then
    echo "Creating symlinks to fix packages that install to /opt"

# Create symlink for /opt to /var/opt since it is not created in the image yet
mkdir -p "/var/opt"
ln -s "/var/opt"  "/opt"
# Create symlinks for each directory specified in recipe.yml
for OPTPKG in "${OPTFIX[@]}"; do
    OPTPKG="${OPTPKG%\"}"
    OPTPKG="${OPTPKG#\"}"
    OPTPKG=$(printf "$OPTPKG")
    mkdir -p "/usr/lib/opt/${OPTPKG}"
    ln -s "../../usr/lib/opt/${OPTPKG}" "/var/opt/${OPTPKG}"
    echo "Created symlinks for ${OPTPKG}"
done
fi




# Add cloudflare-warp.repo to /etc/yum.repos.d/
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo


# Install
rpm-ostree install cloudflare-warp

rpm-ostree install https://github.com/rustdesk/rustdesk/releases/download/nightly/rustdesk-1.3.1-0.x86_64.rpm

# this installs a package from fedora repos
rpm-ostree install screen

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

systemctl enable podman.socket
