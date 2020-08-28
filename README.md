# docker-alpine-s6
![Build & Push to DockerHub](https://github.com/rakheshster/docker-debian-s6/workflows/Buildx%20%26%20Push%20to%20DockerHub/badge.svg)
## What is this?
This is a simple repo to create a Docker image with Debian (slim) and s6-overlay. 

  * The [s6-overlay](https://github.com/just-containers/s6-overlay) provides tarballs for the following architectures: amd64, x86, aarch64, arm, and armhf. 

  * The experimental docker `buildx` plugin can [do mutli-arch builds easily](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/). The architectures it creates images for are: arm, arm64, arm/v7, arm/v6, arm/v8, 386, and amd64. 

This image downloads the correct tarball for the various architectures that and creates images for the architectures that buildx supports. That's all. I can then refer to `rakheshster/debian-s6:buster-2.0.0.1` for instance in my Dockerfile to create new images based on this.  

In `buildx` the `$TARGETARCH` variable contains the architecture while the `$TARGETVARIANT` contains the variant if any. In the case of ARM I use the `$TARGETVARIANT` to identify which of arm, armhf, or aarch64 to target. 

The version numbers are of format `<debian version>-<s6 version>`. 

[DockerHub repo](https://hub.docker.com/repository/docker/rakheshster/alpine-s6)
