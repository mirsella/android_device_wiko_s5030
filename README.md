# Wiko Lenny 2 (s5030) — LineageOS 14.1

Source-only device tree for the **Wiko Lenny 2** (`s5030`, MediaTek MT6580,
1 GB RAM, 8 GB eMMC, 480x854). This tree is based on the
[A2L5-UL device tree](https://github.com/A2L5-UL/android_device_wiko_s5030)
and targets LineageOS 14.1 (Android 7.1.2).

This repository contains source, configuration, SELinux policy, and the small
framework patches needed to reproduce the build. It does **not** contain
vendor binaries, a kernel checkout, prebuilt images, signing keys, or GApps.

## Status

Working on the final `user` build:

- Wi-Fi, Bluetooth (adapter power and scanning), MTP + ADB
- front-camera photos and preview
- microphone input and audio playback
- Quick Settings flashlight (direct MTK flashlight driver)
- zram swap (384 MiB) and low-RAM tuning
- SELinux enforcing, with the legacy MTK daemons in a targeted `mtk_daemon`
  domain
- WebView, `screenrecord`, and the normal LineageOS apps

Known limitations:

- **Rear camera:** the sensor returns black frames. This is a fault in the
  rear camera module/flex, not a software issue.
- **Camera video:** Snap's record button is disabled. Configuring a video
  stream crashes the 5.1 MTK camera HAL in `ParamsManager::updatePreviewSize`
  on the 7.1 stagefright/gralloc stack. Photo capture and `screenrecord` work.
- **Root:** release `user` builds contain no `su` and no `perfprofd`; `adb
  root` is unavailable. A `userdebug` build is available for debugging.
- **Flashing:** the block-image OTA updater fails with E1001 on this recovery.
  Flash `boot` with fastboot and write the raw system image from CWM.
- Boot takes about 19 seconds to the launcher on this hardware; MTK kernel
  threads in `D` state keep the load average high even while the CPU is idle.

## Repository layout

```text
device/wiko/s5030/          this device tree (repository root)
  patches/                  framework/Snap patches applied after repo sync
  manifests/                local manifest for repo
  scripts/                  patch and build helpers
  rootdir/                  init scripts and device configuration
  sepolicy/                 device SELinux policy
  libshims/, libbt-vendor/, liblights/, libwifi-hal/, power/
  proprietary-files.txt     blob list for extract-files.sh
  extract-files.sh          regenerates vendor/wiko/s5030 from a stock ROM
```

## Build

Prerequisites: a Linux host, `repo`, Java 8, the usual LineageOS 14.1 build
dependencies, and a stock Wiko Lenny 2 system image for the vendor blobs.

```bash
mkdir -p ~/android/lineage-14.1
cd ~/android/lineage-14.1
repo init -u https://github.com/LineageOS/android.git -b lineage-14.1
repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

mkdir -p .repo/local_manifests
curl -L \
  https://raw.githubusercontent.com/mirsella/android_device_wiko_s5030/lineage-14.1/manifests/wiko-s5030.xml \
  -o .repo/local_manifests/wiko-s5030.xml
repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

cd device/wiko/s5030
./extract-files.sh /path/to/stock/system
./scripts/apply-patches.sh
```

Then build:

```bash
cd ~/android/lineage-14.1
source build/envsetup.sh
lunch lineage_s5030-userdebug   # or lineage_s5030-user for a release build
mka bacon
```

If the host JDK trips over the old Jack TLS setup, export:

```bash
export JACK_EXTRA_CURL_OPTIONS=--tlsv1.0
```

The `user` variant excludes `su`, `perfprofd`, and other debug-only packages.
The `userdebug` variant is useful for `adb root` and debugging.

## Patches

`scripts/apply-patches.sh` applies the three patches in `patches/` to a synced
LineageOS 14.1 tree:

| Project | Patch | Base commit |
| --- | --- | --- |
| `frameworks/av` | `frameworks_av.patch` | `9988512` |
| `frameworks/base` | `frameworks_base.patch` | `3ea44fbb` |
| `packages/apps/Snap` | `packages_apps_Snap.patch` | `d9563f3` |

The kernel is the upstream
[A2L5-UL kernel](https://github.com/A2L5-UL/android_kernel_wiko_s5030) at
commit `3de7764af7b78ab1b6d7c12b2e2fe4d26531d971`; no kernel patch is required.

The patches contain:

- direct `/dev/kd_camera_flashlight` torch control and removal of the dead
  legacy flash-control path in `CameraFlashlight`;
- a null-preview-window guard for the legacy camera HAL;
- the MTK 5.1 audio `get_capture_position` guard;
- a front-camera profile fallback in `CameraProfile`;
- a fixed camera ID in SystemUI's flashlight controller;
- Snap video recording disabled with a Toast.

## Flashing

Back up the stock boot and system partitions first. Do not relock the
bootloader.

```bash
fastboot flash boot out/target/product/s5030/boot.img
```

For the system partition, convert the sparse image and write it from CWM:

```bash
simg2img out/target/product/s5030/system.img system.raw.img
# in CWM recovery, with the raw image pushed to /data/local/tmp:
dd if=/data/local/tmp/system.raw.img \
  of=/dev/block/platform/mtk-msdc.0/by-name/system bs=4M
sync
```

The raw-system installer used during development is not included here because
it embeds prebuilt images. The tree is intended to reproduce those images
from source and a stock blob dump.

## Credits

- A2L5-UL for the original `android_device_wiko_s5030` and kernel trees
- The LineageOS project
- The CyanogenMod/LineageOS Snap, `frameworks_av`, and `frameworks_base`
  contributors whose code these patches modify

## License

The device tree is licensed under the Apache License 2.0; see `LICENSE`.
The upstream kernel is GPLv2. Vendor blobs extracted from a stock ROM remain
subject to their original licenses and are not distributed here.
