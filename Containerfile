FROM ghcr.io/ublue-os/bluefin-dx:41



COPY build.sh /tmp/build.sh
COPY scripts/* /tmp/

COPY etc/containers/ /etc/containers/
COPY usr/bin/ /usr/bin/

COPY cosign.pub /etc/pki/containers/xlion-private.pub

RUN /usr/bin/update-sigstore-certs.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/zerotier.sh &&\
    /tmp/build.sh && \
    ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
