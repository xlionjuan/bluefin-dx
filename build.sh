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

# >>>>>>>>>> RustDesk

# Define the repository and the tag you want to fetch
REPO="rustdesk/rustdesk"
TAG="nightly"  # Change this to any tag you want
API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"

# Fetch the release data for the specified tag using curl
RELEASE_DATA=$(curl -s "$API_URL")

# Check if RELEASE_DATA is not empty
if [ -z "$RELEASE_DATA" ]; then
    echo "Failed to fetch release data. Please check your internet connection or the repository/tag name."
    exit 1
fi

# Parse JSON data without using jq to find the asset URL
RUSTDESK_URL=""
found=0

# Read the JSON data line by line
while IFS= read -r line; do
    if echo "$line" | grep -q '"name"'; then
        name=$(echo "$line" | sed 's/.*"name": "\(.*\)",*/\1/')
        # Check if the name contains "x86_64" and ".rpm" and does not contain "suse"
        if echo "$name" | grep -q "x86_64" && echo "$name" | grep -q "\.rpm" && ! echo "$name" | grep -q "suse"; then
            found=1
        else
            found=0
        fi
    elif echo "$line" | grep -q '"browser_download_url"'; then
        if [ "$found" -eq 1 ]; then
            RUSTDESK_URL=$(echo "$line" | sed 's/.*"browser_download_url": "\(.*\)",*/\1/')
            break
        fi
    fi
done <<< "$RELEASE_DATA"

# Check if the asset URL was found
if [ -z "$RUSTDESK_URL" ]; then
    echo "No matching file found."
else
    echo "RUSTDESK_URL=\"$RUSTDESK_URL\""
fi


rpm-ostree install $RUSTDESK_URL
# <<<<<<<<<< RustDesk



# Add cloudflare-warp.repo to /etc/yum.repos.d/
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo

# Install
rpm-ostree install cloudflare-warp screen libwebp-tools tuned waydroid

# this installs a package from fedora repos
#rpm-ostree install screen

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

#systemctl enable podman.socket
