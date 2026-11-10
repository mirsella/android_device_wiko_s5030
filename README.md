# Wiko Lenny 2 (s5030) LineageOS 14.1 device tree

Device tree for the Wiko Lenny 2 (s5030), a MediaTek MT6580 phone with 1 GB
RAM, 8 GB eMMC, and a 480x854 screen. It builds LineageOS 14.1 (Android
7.1.2) and is based on
[A2L5-UL's device tree](https://github.com/A2L5-UL/android_device_wiko_s5030).

The repository contains the source, configuration, SELinux policy, and
framework patches needed to build the ROM. It does not include vendor
binaries, kernel source, prebuilt images, signing keys, or GApps.

## Status

These features work in the final `user` build:

- Wi-Fi, Bluetooth (adapter power and scanning), MTP + ADB
- front-camera photos and preview
- microphone input and audio playback
- Quick Settings flashlight (direct MTK flashlight driver)
- zram swap (384 MiB) and low-RAM tuning
- SELinux enforcing, with the legacy MTK daemons in a targeted `mtk_daemon`
  domain
- WebView, `screenrecord`, and the normal LineageOS apps

## Limitations

The rear camera returns black frames. The sensor module or flex is faulty;
software changes do not fix it.

Snap's record button is disabled. Configuring a video stream crashes the 5.1
MTK camera HAL in `ParamsManager::updatePreviewSize` when it runs on the 7.1
stagefright/gralloc stack. Photo capture and `screenrecord` still work.

Release `user` builds have no `su` and no `perfprofd`, so `adb root` does not
work. Build `userdebug` if you need root or debugging tools.

The block-image OTA updater fails with E1001 on this recovery. Flash `boot`
with fastboot and write the raw system image from CWM.

Boot takes about 19 seconds to the launcher. MTK kernel threads in `D` state
keep the load average high even when the CPU is idle.

## Repository layout

The repository root is the device tree.

```text
device/wiko/s5030/
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

You need Linux, `repo`, Java 8, the usual LineageOS 14.1 build dependencies,
and a stock Wiko Lenny 2 system image for the vendor blobs.

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

If Jack fails on the host JDK's TLS settings, set:

```bash
export JACK_EXTRA_CURL_OPTIONS=--tlsv1.0
```

The `user` variant leaves out `su`, `perfprofd`, and other debug-only
packages. Use `userdebug` if you want `adb root` or debugging.

## Patches

`scripts/apply-patches.sh` applies the three patches in `patches/` after
`repo sync`:

| Project | Patch | Base commit |
| --- | --- | --- |
| `frameworks/av` | `frameworks_av.patch` | `9988512` |
| `frameworks/base` | `frameworks_base.patch` | `3ea44fbb` |
| `packages/apps/Snap` | `packages_apps_Snap.patch` | `d9563f3` |

The kernel comes from the
[A2L5-UL kernel](https://github.com/A2L5-UL/android_kernel_wiko_s5030) at
commit `3de7764af7b78ab1b6d7c12b2e2fe4d26531d971`; no kernel patch is needed.

The patches:

- drive the torch directly through `/dev/kd_camera_flashlight` and remove the
  old flash-control path from `CameraFlashlight`
- guard against a null preview window in the legacy camera HAL
- skip `get_capture_position` for the MTK 5.1 audio HAL
- fall back to a working front-camera profile in `CameraProfile`
- use a fixed camera ID in SystemUI's flashlight controller
- disable Snap video recording and show a Toast

## Flashing

Back up the stock boot and system partitions first, and do not relock the
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

The raw-system installer from development is not here because it contains
prebuilt images. This tree is meant to rebuild those images from source and a
stock blob dump.

## Credits

- A2L5-UL for the original `android_device_wiko_s5030` and kernel trees
- The LineageOS project
- The CyanogenMod/LineageOS Snap, `frameworks_av`, and `frameworks_base`
  contributors whose code these patches modify

## License

The device tree is licensed under the Apache License 2.0; see `LICENSE`.
The upstream kernel is GPLv2. Vendor blobs extracted from a stock ROM remain
subject to their original licenses and are not distributed here.
