#!/bin/bash
set -ouex pipefail

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

# Use jq to parse JSON data and find the asset URL
RUSTDESK_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(
    (.name | contains("x86_64")) and
    (.name | endswith(".rpm")) and
    (.name | contains("suse") | not) and
    (.name | contains("sciter") | not)
) | .browser_download_url' | head -n 1)

# Check if the asset URL was found
if [ -z "$RUSTDESK_URL" ]; then
    echo "No matching file found."
else
    echo "RUSTDESK_URL=\"$RUSTDESK_URL\""
fi


rpm-ostree install $RUSTDESK_URL
