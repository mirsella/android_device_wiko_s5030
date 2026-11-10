#
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

## Common
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_l_mr1.mk)

## Device
$(call inherit-product, device/wiko/s5030/device.mk)

## LineageOS
$(call inherit-product, vendor/cm/config/common_mini_phone.mk)

## Trim the package list for a 1 GB / MT6580 device.  Keep one app per job:
## Trebuchet (launcher), Jelly (browser), Snap (camera), Gallery2 (photos),
## Eleven (music), ExactCalculator, and the telephony stack.
PRODUCT_PACKAGES := $(filter-out \
    AudioFX \
    Camera2 \
    EasterEgg \
    Exchange2 \
    LiveWallpapersPicker \
    LockClock \
    Music \
    MusicFX \
    PhotoTable \
    Recorder \
    Terminal \
    Updater \
    WeatherManagerService \
    WeatherProvider \
    7z \
    bzip2 \
    fsck.ntfs \
    gdbserver \
    htop \
    lib7z \
    micro_bench \
    mkfs.ntfs \
    mount.ntfs \
    oprofiled \
    pigz \
    powertop \
    rsync \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh \
    strace \
    unrar \
    vim \
    ,$(PRODUCT_PACKAGES))

# Device identifier
PRODUCT_NAME := lineage_s5030
PRODUCT_DEVICE := s5030
PRODUCT_BRAND := wiko
PRODUCT_MODEL := Lenny2
PRODUCT_MANUFACTURER := Wiko
PRODUCT_GMS_CLIENTID_BASE := android-wiko
