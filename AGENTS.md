# Repository guidance

## Project

This repository is an OpenWrt tree configured for the Cudy WR3000H v1 on the
MediaTek Filogic target (`aarch64_cortex-a53`). It builds a customized firmware
image with packages and files selected in this repository.

## Configuration

- Keep intentional package and target selections in `config.seed`.
- Do not edit `.config` as a source file. `make.sh` copies `config.seed` to
  `.config` and expands it with `make defconfig`.
- Treat `.config`, feed links, build directories, staging directories, and
  other ignored build output as generated state.
- Preserve the existing OpenWrt package layout and use an existing package
  before adding a new implementation.
- Keep device overlay changes under `files/` and avoid changing generated
  configuration under `files/etc/config/` unless the change is intentional.

## Build workflow

The standard build is:

```fish
./make.sh
```

This updates and installs all feeds, regenerates the expanded configuration,
synchronizes router configuration files from `~/src/routers/`, and builds with
`files/` as the image overlay. The router configuration source must exist when
running this script.

## Agent execution restriction

- Never run compilation, package builds, firmware builds, or other build targets inside the development container.
- Use the container only for static inspection, patch dry-runs, formatting and whitespace checks, and repository verification.
- Run compilation and firmware builds only through the host workflow.

For configuration-only checks after feeds are installed, run:

```fish
cp config.seed .config
make defconfig
```

Use a targeted package or image build when it provides enough coverage; avoid
a full firmware build for changes that only affect metadata or documentation.

## Verification

For every change:

- Run `git diff --check`.
- Run the smallest relevant OpenWrt configuration, package, or image check.
- Report blocked checks and their actual errors instead of treating them as
  successful.
- Inspect the final diff for unrelated generated files before committing.

Match surrounding OpenWrt style. Keep changes minimal and do not add
application-specific abstractions or dependencies without a demonstrated need.
