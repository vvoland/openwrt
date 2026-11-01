# syntax=docker/dockerfile:1

FROM debian:13-slim AS build

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

ARG JOBS=12
ARG REVISION=unknown

RUN --mount=type=bind,from=openwrt,target=/src \
    --mount=type=bind,target=/custom \
    --mount=type=bind,from=overlay,target=/overlay \
    --mount=type=bind,from=router-config,target=/router-config \
    --mount=type=cache,id=openwrt-dl,target=/build/dl,sharing=locked \
    --mount=type=cache,id=openwrt-feeds,target=/build/feeds,sharing=locked <<'EOF'
set -eu
export LC_ALL=C
cp -a /src/. .
for patch in /custom/patches/*.patch; do
    [ -f "$patch" ] || continue
    git apply --verbose "$patch"
done
cp -a /custom/config.seed ./
mkdir -p files/etc/config /out /builder/src/routers
cp -a /overlay/. files/
cp -a /router-config/. /builder/src/routers/
chown -R builder:builder /build /out /builder/src/routers
su builder -s /bin/sh <<'BUILD'
set -ex
./scripts/feeds update -a
./scripts/feeds install -a
cp config.seed .config
printf 'CONFIG_VERSION_CODE="custom-%s"\n' "$REVISION" >> .config
make defconfig
rsync --delete -a ~/src/routers/ ./files/etc/config/
make -j"$JOBS"
cp -a bin/. /out/
BUILD
EOF

FROM scratch AS firmware
COPY --from=build /out/ /
