FROM ghcr.io/openwrt/buildbot/buildworker-v3.8.0:v9

USER root

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
      binutils \
      file \
      git \
      jq \
      make \
      ripgrep \
      shellcheck \
 && rm -rf /var/lib/apt/lists/*
