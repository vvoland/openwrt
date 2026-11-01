#!/bin/sh
set -eu
export LC_ALL=C

# Serialize builds that share either cache volume.
exec 9>/build/dl/.build.lock
flock 9
exec 8>/build/feeds/.build.lock
flock 8

# Stage private host inputs before dropping privileges.
mkdir -p /builder/custom /builder/overlay /builder/src/routers
cp -a /custom/. /builder/custom/
cp -a /overlay/. /builder/overlay/
cp -a /router-config/. /builder/src/routers/
chown -R builder:builder /build /builder/custom /builder/overlay /builder/src
su builder -s /bin/sh <<'BUILD'
set -ex

git init .
git remote add origin https://git.openwrt.org/openwrt/openwrt.git
git fetch --depth=1 origin "$OPENWRT_REF"
git checkout --detach FETCH_HEAD
for patch in /builder/custom/patches/*.patch; do
    [ -f "$patch" ] || continue
    git apply --verbose "$patch"
done

mkdir -p files/etc/config
cp -a /builder/overlay/. files/
./scripts/feeds update -a
./scripts/feeds install -a
cp /builder/custom/config.seed .config
printf 'CONFIG_VERSION_CODE="custom-%s"\n' "$REVISION" >> .config
make defconfig
rsync --delete -a ~/src/routers/ ./files/etc/config/
make -j"$JOBS"
BUILD

cp -a /build/bin/. /out/
chown -R "$HOST_UID:$HOST_GID" /out
