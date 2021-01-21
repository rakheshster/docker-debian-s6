################################### STAGE ONE ####################################
ARG DEBIAN_VERSION=buster-slim
FROM --platform=$TARGETPLATFORM debian:${DEBIAN_VERSION} AS debianbuild

LABEL maintainer="Rakhesh Sasidharan"
ENV S6_VERSION 2.2.0.0
ARG TARGETARCH
ARG TARGETVARIANT

# Install GnuPG so I can install the public key of the s6 folks. Also wget. Remove it later. 
RUN apt-get update && apt-get install -y wget gnupg
RUN wget -qO - https://keybase.io/justcontainers/key.asc | gpg --import

# COPY over my script to download s6. Remove /var/run as it's a link to /run and causes issues in the COPY block later. 
# RUN the script and delete it.
COPY ./gets6.sh /tmp
RUN rm -f /var/run 
RUN /tmp/gets6.sh $S6_VERSION $TARGETARCH $TARGETVARIANT

# At this point the build will either exit or continue depending on the exit status of gets6.sh
RUN rm -f /tmp/gets6.sh
RUN rm -rf /root/.gnupg
# I have to remove this stuff lest it gets copied over in the next stage (as I am copying from /)
RUN apt-get purge -y --auto-remove gnupg
RUN rm -rf /var/lib/{apt,dpkg,cache,log}/

################################### STAGE TWO ####################################
# Doing a new build just so I can get rid of that /tmp/gets6.sh from any of the layers coz of my OCD ...
ARG DEBIAN_VERSION=buster-slim
FROM --platform=$TARGETPLATFORM debian:${DEBIAN_VERSION}

RUN rm -f /var/run 
COPY --from=debianbuild / /

ENTRYPOINT ["/init"]
