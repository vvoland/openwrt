# syntax=docker/dockerfile:1

FROM debian:13-slim

# Debian's cleanup hook would empty the apt download cache.
RUN rm -f /etc/apt/apt.conf.d/docker-clean

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      bison \
      build-essential \
      bzip2 \
      ca-certificates \
      file \
      flex \
      gawk \
      gettext \
      git \
      gnu-which \
      libelf-dev \
      libncurses-dev \
      libssl-dev \
      patch \
      perl \
      pkgconf \
      python3 \
      python3-setuptools \
      rsync \
      swig \
      time \
      unzip \
      util-linux \
      wget \
      xz-utils \
      zlib1g-dev \
      zstd

RUN useradd --create-home --user-group --home-dir /builder --shell /bin/bash builder

WORKDIR /build
