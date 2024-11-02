#!/usr/bin/bash

set -eux

# very much non standard; will this be a problem?
container_pki_dir="/etc/pki/containers"

# Fulcio swagger docs: https://rekor.sigstore.dev/api/v1/log/publicKey
fulcio_cert_url="https://fulcio.sigstore.dev/api/v2/trustBundle"

# Rekor swagger docs: https://rekor.sigstore.dev/api/v1/log/publicKey
rekor_pubkey_url="https://rekor.sigstore.dev/api/v1/log/publicKey"

[[ -d "$container_pki_dir" ]] || mkdir -p "$container_pki_dir"

curl -L "$fulcio_cert_url" | jq -j '.chains[].certificates | join("")' > \
    "$container_pki_dir"/fulcio.sigstore.dev.pub.tmp && \
    mv "$container_pki_dir"/fulcio.sigstore.dev.pub.tmp \
    "$container_pki_dir"/fulcio.sigstore.dev.pub && \
    cat "$container_pki_dir"/fulcio.sigstore.dev.pub

curl -L -o "$container_pki_dir"/rekor.sigstore.dev.pub "$rekor_pubkey_url" && \
    cat "$container_pki_dir"/rekor.sigstore.dev.pub
