# Cudy WR3000H firmware

Build customized OpenWrt firmware for the Cudy WR3000H v1 without maintaining an OpenWrt source checkout.
Docker BuildKit fetches the upstream source and applies the configuration, patches, and overlay in this repository.

## Build

Run on the host with Make, Git, Docker, and the Buildx plugin available:

```fish
make
```

The Makefile reads this repository's Git revision and runs `docker buildx bake`.
Use `BAKE_ARGS` to pass additional Bake arguments.
Firmware versions are labeled `custom-<revision>`.
Build artifacts are exported to `bin/`.
Calling Bake directly without setting `REVISION` produces `custom-unknown`.

Router configuration must exist at `~/src/routers/`.
The build synchronizes it into `/etc/config` in the firmware, replacing any configuration from the overlay.
To use a different directory:

```fish
make BAKE_ARGS='--set firmware.contexts.router-config=/path/to/routers'
```

Router configuration and overlay contents become part of the firmware.
Use a trusted builder and protect exported images if they contain credentials.
Local signing keys are not sent to the builder; the build generates fresh keys.

## Customization

- `docker-bake.hcl` selects the upstream OpenWrt ref, defaulting to `v25.12.6`.
- `config.seed` selects the device and packages.
- `patches/*.patch` contains source changes, applied in filename order.
- `files/` supplies the firmware filesystem overlay.
- `Dockerfile` runs the firmware build inside the fetched source tree.

Change `OPENWRT_REF` in `docker-bake.hcl` to select another release without rebasing this repository.
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

## Build environment

The build stage uses Debian 13 with explicit OpenWrt host dependencies and runs compilation as a non-root `builder` user.
Source inputs use read-only bind mounts, and apt, source downloads, and feeds use locked BuildKit caches.
The local source context includes only `config.seed` and `patches/*.patch`.
Build artifacts are copied outside the mounts before export, so empty caches are safe.
