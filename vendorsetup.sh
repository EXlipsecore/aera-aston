#!/bin/bash
#
# Copyright (C) 2026 AERA Recovery Project contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#

FDEVICE="aston"

aera_get_target_device() {
    local chkdev=$(echo "$BASH_SOURCE" | grep -w $FDEVICE)
    if [ -n "$chkdev" ]; then
        AERA_BUILD_DEVICE="$FDEVICE"
    else
        chkdev=$(set | grep BASH_ARGV | grep -w $FDEVICE)
        [ -n "$chkdev" ] && AERA_BUILD_DEVICE="$FDEVICE"
    fi
}

if [ -z "$1" -a -z "$AERA_BUILD_DEVICE" ]; then
    aera_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$AERA_BUILD_DEVICE" = "$FDEVICE" ]; then
    export LC_ALL="C"
    export AERA_BUILD_DEVICE="aston"
    export AERA_MAINTAINER="EXlipse"
    export AERA_PRODUCT_PREFIX="AERA"
    export AERA_BUILD_STATUS="${AERA_BUILD_STATUS:-Unofficial}"
    export AERA_BUILD_TYPE="Beta"
    export AERA_VANILLA_BUILD=1

    export AERA_AB_DEVICE=1
    export AERA_VIRTUAL_AB_DEVICE=1
    export AERA_AB_DEVICE_WITH_RECOVERY_PARTITION=1

    # OnePlus 12R (aston) & OnePlus Ace 3 (astonc) variants
    export TARGET_DEVICE_ALT="astonc,OP5D35L1,OP5CF9L1,CPH2585,CPH2609,CPH2609EEA,CPH2611,PJE110,ossi,qssi"
    export AERA_TARGET_DEVICES="aston,$TARGET_DEVICE_ALT"

    export AERA_ENABLE_FRP_WIPE=1
    export AERA_ENABLE_WLAN=1
    export AERA_ENABLE_ABL_PRESERVATION=1
    export AERA_USE_AIDL_BOOT_CONTROL=1
    export AERA_USE_DMSETUP=1
    export AERA_ENABLE_ROOT_MANAGER=1
    export AERA_ENABLE_APP_MANAGER=1
    unset AERA_ROOT_MODULE_KERNELS
    export AERA_DELETE_MAGISK_ADDON=1
    export AERA_DELETE_AROMAFM=1
    export AERA_ALLOW_EARLY_SETTINGS_LOAD=1
    export AERA_USE_UPDATED_MAGISKBOOT=1
    export AERA_USE_FSCK_EROFS_BINARY=1
    export AERA_USE_PATCHELF_BINARY=1
    export AERA_SETTINGS_ROOT_DIRECTORY=/data/recovery
    export AERA_MISCELLANEOUS_ROOT_DIRECTORY=/sdcard

    export AERA_SCREEN_H=2310
    export AERA_STATUS_H=132
    export AERA_HIDE_NOTCH=1
    export AERA_STATUS_INDENT_LEFT=64
    export AERA_STATUS_INDENT_RIGHT=48
    export AERA_CLOCK_POS=1

    export AERA_USE_TAR_BINARY=1
    export AERA_USE_SED_BINARY=1
    export AERA_USE_XZ_UTILS=1
    export AERA_USE_LZ4_BINARY=1
    export AERA_USE_ZSTD_BINARY=1
    export AERA_USE_DATE_BINARY=1
    export AERA_USE_GREP_BINARY=1
    export AERA_USE_BUSYBOX_BINARY=1

    unset AERA_MAINTAINER_PATCH_VERSION
fi
