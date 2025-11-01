#!/bin/bash
set -xe

./scripts/feeds update -a
./scripts/feeds install -a

revision=$(git rev-parse --short HEAD)
cp config.seed .config
printf 'CONFIG_VERSION_CODE="custom-%s"\n' "$revision" >> .config
make defconfig

rsync --delete -a ~/src/routers/ ./files/etc/config/

make FILES=files -j12
