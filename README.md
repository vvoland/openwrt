# Cudy WR3000H firmware

Build customized OpenWrt firmware for the Cudy WR3000H v1 without maintaining an OpenWrt source checkout.
The Dockerfile provides the build environment; a running container fetches upstream source and builds the firmware using this repository's configuration, patches, and overlay.

## Build

Run on the host with Make, Git, and Docker available:

```fish
make
```

The Makefile builds the dependency image, then runs `build.sh` with `docker run --rm`.
Firmware compilation does not run in a Dockerfile or require Buildx/Bake.
The Makefile reads this repository's Git revision to label firmware versions `custom-<revision>`.
Build artifacts are copied to `bin/` and owned by the invoking host user.

Router configuration must exist at `~/src/routers/`.
The build synchronizes it into `/etc/config` in the firmware, replacing any configuration from the overlay.
To use a different directory:

```fish
make ROUTER_CONFIG=/path/to/routers
```

Router configuration and overlay contents become part of the firmware.
Use a trusted Docker host and protect exported images if they contain credentials.
Local signing keys are not mounted into the container; the build generates fresh keys.

## Customization

- `Makefile` selects the upstream OpenWrt ref, defaulting to `v25.12.6`.
- `config.seed` selects the device and packages.
- `patches/*.patch` contains source changes, applied in filename order.
- `files/` supplies the firmware filesystem overlay.
- `Dockerfile` provides Debian 13 and the OpenWrt host dependencies.
- `build.sh` fetches, configures, and compiles OpenWrt inside the running container.

Change `OPENWRT_REF` in `Makefile` to select another release without rebasing this repository.
It accepts a tag, branch, or full 40-character commit hash.
The selected upstream source also supplies the feed definitions.
Override the ref or build parallelism for one invocation:

```fish
env OPENWRT_REF=v25.12.6 JOBS=8 make
```

Export source changes with `git format-patch` and give the patch files numbered names to define their order.
Patches are applied with `git apply` before configuration and compilation.
A patch that no longer applies stops the build; an empty or absent patch directory is allowed.
Recheck patches whenever the upstream ref changes.
The included patch restores the smaller MT7915 TX-ring experiment only for the Cudy WR3000H; it does not enable WED.

## Build environment and caches

Compilation runs as a non-root `builder` user in a disposable container.
Only the build script, seed configuration, patches, overlay, and router configuration are bind-mounted as read-only inputs.
The Docker image build context excludes repository contents; no firmware inputs or secrets are copied into the image.
Source and compilation outputs are recreated on each run, while named Docker volumes `openwrt-dl` and `openwrt-feeds` retain downloads and feeds between builds.
Empty cache volumes are initialized automatically, and builds sharing caches are serialized with file locks.
These firmware caches live on the Docker host, not in BuildKit.
The dependency image uses locked BuildKit caches for apt downloads and package indexes.

Use a different cache prefix to keep independent caches or run builds concurrently with separate output directories:

```fish
make CACHE_PREFIX=openwrt-test
```

Set `IMAGE` to override the dependency image name, which defaults to `openwrt-builder`.
