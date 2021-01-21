#!/bin/sh

# This script downloads s6-overlay and extracts it into the root folder. The version and architecture as specified as arguments. This is meant to be invoked from my Dockerfile via docker buildx. 
# The $TARGETARCH variable contains the architecture. However, this is normalized as per https://github.com/containerd/containerd/blob/master/platforms/platforms.go#L80 and does not match what s6 expects so I map that to the ARCH variable. 
# The $TARGETVARIANT variable contains the variant of the architecture. This is only useful in the ARM case currently. 
S6_VERSION=$1
TARGETARCH=$2
TARGETVARIANT=$3

case ${TARGETARCH} in
    arm) \
    	case ${TARGETVARIANT} in
            v6)
                ARCH="arm"
                ;;
            v7)
                ARCH="armhf"
                ;;
            v8)
                ARCH="aarch64"
                ;;
        esac
        ;;
    arm64)
	ARCH="aarch64"
	;;
    386)
        ARCH="x86"
        ;;
    amd64)
        ARCH="amd64"
        ;;
esac

# The default instructions give the impression one must do a 2-stage extract. That's only to target this issue - https://github.com/just-containers/s6-overlay#known-issues-and-workarounds
# Download s6 to /tmp (-P says put it that location), download the s6 signature, compare, and extract if all good
# Thanks to https://superuser.com/a/497971 for the gpg --status-fd trick
wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${ARCH}.tar.gz -P /tmp/ &&
wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${ARCH}.tar.gz.sig -P /tmp/ &&
gpg --status-fd 1 --verify /tmp/s6-overlay-${ARCH}.tar.gz.sig /tmp/s6-overlay-${ARCH}.tar.gz 2>/dev/null | grep -q "GOODSIG .*Just Containers Bot"

# If the status check above has failed then exit
if [[ $? -eq 0 ]]; then
    echo "Tarball signature is good! Extracting."
    tar xzf /tmp/s6-overlay-${ARCH}.tar.gz -C / &&
    rm  -f /tmp/s6-overlay-${ARCH}.tar.gz &&
    rm  -f /tmp/s6-overlay-${ARCH}.tar.gz.sig
    exit 0
else
    echo "Tarball signature is bad! Exiting."
    exit 1
fi