#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 AERA Recovery Project contributors
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/oneplus/aston

# Shipping API level
BOARD_SHIPPING_API_LEVEL    := 33
PRODUCT_SHIPPING_API_LEVEL  := 33
PRODUCT_TARGET_VNDK_VERSION := 33

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

# Dynamic partitions & Virtual A/B OTA
PRODUCT_USE_DYNAMIC_PARTITIONS                := true
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
PRODUCT_ENABLE_UFFD_GC                        := true
AB_OTA_UPDATER                                := true

AB_OTA_PARTITIONS += \
    abl \
    aop \
    aop_config \
    bluetooth \
    boot \
    cpucp \
    devcfg \
    dsp \
    dtbo \
    engineering_cdt \
    featenabler \
    hyp \
    imagefv \
    init_boot \
    keymaster \
    modem \
    odm \
    oplus_sec \
    oplusstanvbk \
    product \
    qupfw \
    recovery \
    shrm \
    splash \
    system \
    system_dlkm \
    system_ext \
    tz \
    uefi \
    uefisecapp \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm \
    xbl \
    xbl_config \
    xbl_ramdump

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

# OTA signing certificates
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(LOCAL_PATH)/security/local_OTA \
    $(LOCAL_PATH)/security/special_OTA

# Properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.ota.allow_downgrade=true \
    ro.virtual_ab.compression.threads=true \
    ro.virtual_ab.batch_writes=true

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl=adreno \
    vendor.gatekeeper.disable_spu=true \
    vendor.gatekeeper.is_security_level_spu=0

# Recovery & HAL packages
PRODUCT_PACKAGES += \
    aston_file_contexts.recovery \
    android.hardware.boot-service.qti.recovery \
    vendor.qti.hardware.vibrator.service.oplus_aston \
    aston_vibrator.recovery \
    wpa_supplicant

# Crypto & graphics compatibility libraries
PRODUCT_PACKAGES += \
    libaston_rkp_v3_compat \
    aston_rkp_v3_compat.recovery \
    libaston_keymint_v2_compat \
    aston_keymint_v2_compat.recovery \
    libdrm.vendor \
    aston_libdrm.recovery \
    libsync \
    aston_libsync.recovery \
    libkeymaster_messages.vendor \
    aston_km_messages.recovery \
    android.hardware.security.secureclock-V1-ndk.vendor \
    aston_secureclock_v1.recovery \
    android.hardware.security.sharedsecret-V1-ndk.vendor \
    aston_sharedsecret_v1.recovery \
    android.hardware.gatekeeper@1.0 \
    aston_gk10.recovery \
    android.hardware.keymaster@4.0 \
    aston_km40.recovery \
    android.hardware.keymaster@4.1 \
    aston_km41.recovery \
    android.hidl.allocator@1.0 \
    aston_hidl_alloc.recovery \
    android.hidl.memory@1.0 \
    aston_hidl_mem.recovery \
    libhidlmemory \
    aston_hidlmemory.recovery \
    android.hidl.memory.token@1.0 \
    libdmabufheap \
    libion \
    libfs_mgr_binder \
    libsnapshot \
    libbinderdebug \
    libhidl-gen-hash

# GPU validation probe (see gpu/README.md)
PRODUCT_PACKAGES += \
    aera-gpu-probe

# Hosts the stock AGM/PAL implementation from the installed vendor partition
PRODUCT_PACKAGES += \
    aera-audio-service

# Partition & OTA utilities
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier \
    fastbootd \
    lpflash \
    lpmake \
    lpunpack \
    sg_write_buffer \
    f2fs_io \
    check_f2fs

# AERA configuration
$(call inherit-product, $(LOCAL_PATH)/aera_aston.mk)
