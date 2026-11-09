#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 AERA Recovery Project contributors
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oneplus/aston

# Minimal manifest build flags
ALLOW_MISSING_DEPENDENCIES                   := true
BUILD_BROKEN_DUP_RULES                       := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_NINJA_USES_ENV_VARS             += RTIC_MPGEN
BUILD_BROKEN_PLUGIN_VALIDATION               := soong-libaosprecovery_defaults soong-libguitwrp_defaults soong-libminuitwrp_defaults soong-vold_defaults

# Architecture
TARGET_ARCH                := arm64
TARGET_ARCH_VARIANT        := armv8-2a-dotprod
TARGET_CPU_ABI             := arm64-v8a
TARGET_CPU_VARIANT         := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

# Platform
TARGET_BOARD_PLATFORM     := kalama
TARGET_BOARD_PLATFORM_GPU := qcom-adreno740
TARGET_USES_VULKAN        := true
QCOM_BOARD_PLATFORMS      += kalama

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := aston
TARGET_NO_BOOTLOADER         := true
TARGET_USES_UEFI             := true

# Kernel & Boot image (GKI Boot Header v4)
BOARD_BOOT_HEADER_VERSION               := 4
BOARD_RAMDISK_USE_LZ4                   := true
BOARD_KERNEL_IMAGE_NAME                 := Image
TARGET_PREBUILT_KERNEL                  := kernel/prebuilts/6.1/arm64/kernel-6.1
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
BOARD_KERNEL_PAGESIZE                   := 4096
BOARD_MKBOOTIMG_ARGS                    += --header_version $(BOARD_BOOT_HEADER_VERSION) --pagesize $(BOARD_KERNEL_PAGESIZE)

# Partitions
BOARD_FLASH_BLOCK_SIZE                 := 262144
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE     := 0x6400000
BOARD_BOOTIMAGE_PARTITION_SIZE         := 0x0c000000
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE   := 0x00800000
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE  := 0x0c000000
BOARD_DTBOIMG_PARTITION_SIZE           := 0x01800000

# Dynamic partitions
BOARD_SUPER_PARTITION_SIZE                  := 16642998272
BOARD_SUPER_PARTITION_GROUPS                := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE           := 16638803968
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor \
    odm \
    vendor_dlkm \
    system_dlkm \
    my_product \
    my_engineering \
    my_company \
    my_carrier \
    my_region \
    my_heytap \
    my_stock \
    my_preload \
    my_bigball \
    my_manifest

# Filesystems
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_METADATA_PARTITION        := true
RECOVERY_SDCARD_ON_DATA              := true
TARGET_USERIMAGES_USE_EXT4           := true
TARGET_USERIMAGES_USE_F2FS           := true
TARGET_COPY_OUT_VENDOR               := vendor
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE      := ext4
TARGET_COPY_OUT_ODM                  := odm
AERA_USE_DMCTL                       := true
BOARD_ROOT_EXTRA_FOLDERS             := acct apex config firmware persist postinstall
BOARD_RECOVERY_ROOT_RSYNC_EXCLUDE    := odm/etc odm/firmware odm/vendor

# Verified Boot (AVB)
BOARD_AVB_ENABLE                           := true
BOARD_AVB_RECOVERY_KEY_PATH                := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM               := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX          := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

# Init & Variant detection
VENDOR_SECURITY_PATCH          := 2026-09-01
AERA_DEVICE_VERSION            := OnePlus_12R_Ace3
TARGET_INIT_VENDOR_LIB         := //$(DEVICE_PATH):libinit_aston
TARGET_RECOVERY_DEVICE_MODULES := libinit_aston
# debug tooling
TARGET_RECOVERY_DEVICE_MODULES += debuggerd
TARGET_RECOVERY_DEVICE_MODULES += strace
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/strace
TARGET_OTA_ASSERT_DEVICE       := aston,astonc,OP5D35L1,OP5CF9L1,CPH2585,CPH2609,CPH2609EEA,CPH2611,PJE110,ossi,qssi

# Recovery & Display
TARGET_RECOVERY_FSTAB          := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
AERA_SKIP_ADDITIONAL_FSTAB     := true
TARGET_RECOVERY_QCOM_RTC_FIX   := true
TARGET_RECOVERY_PIXEL_FORMAT   := RGBX_8888
TARGET_USES_MKE2FS             := true
TW_USE_LEGACY_BATTERY_SERVICES := true

AERA_THEME                  := portrait_hdpi
AERA_UI_ADAPTIVE_RESOLUTION := true
AERA_DRM_FIXED_REFRESH_RATE := 120
AERA_STATUS_ICONS_ALIGN     := center
AERA_BRIGHTNESS_PATH        := "/sys/class/backlight/panel0-backlight/brightness"
AERA_MAX_BRIGHTNESS         := 4094
AERA_DEFAULT_BRIGHTNESS     := 2048
AERA_CUSTOM_CPU_TEMP_PATH   := "/tmp/aston-cpu-temp"
AERA_FRAMERATE              := 120
AERA_NO_SCREEN_BLANK        := true

# Crypto (FBEv2)
AERA_INCLUDE_CRYPTO               := true
AERA_INCLUDE_CRYPTO_FBE           := true
AERA_INCLUDE_FBE_METADATA_DECRYPT := true
AERA_USE_FSCRYPT_POLICY           := 2

# Storage & Tools
AERA_ENABLE_FS_COMPRESSION          := true
AERA_INCLUDE_NTFS_3G                := true
AERA_INCLUDE_FUSE_NTFS              := true
AERA_INCLUDE_FUSE_EXFAT             := true
AERA_NO_EXFAT_FUSE                  := true
AERA_INCLUDE_7ZA                    := true
AERA_INCLUDE_ZSTD                   := true
AERA_INCLUDE_FASTBOOTD              := true
AERA_INCLUDE_LPDUMP                 := true
AERA_INCLUDE_LPTOOLS                := true
AERA_INCLUDE_RESETPROP              := true
AERA_INCLUDE_LIBRESETPROP           := true
AERA_EXCLUDE_APEX                   := true
AERA_EXCLUDE_LIBXML2                := true
AERA_EXCLUDE_DEFAULT_USB_INIT       := true
AERA_DEFAULT_LANGUAGE               := en
AERA_EXTRA_LANGUAGES                := true
AERA_USE_TOOLBOX                    := true
AERA_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
AERA_HAS_EDL_MODE                   := true
AERA_INCLUDE_LOGCAT                 := true
TARGET_USES_LOGD                    := true
AERA_INPUT_BLACKLIST                := "hbtp_vm"
AERA_SUPPORT_INPUT_FF_HAPTICS       := true

AERA_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libfs_mgr_binder.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libsnapshot.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libbinderdebug.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libhidl-gen-hash.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hidl.allocator@1.0.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hidl.memory@1.0.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hidl.memory.token@1.0.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libhidlmemory.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libdmabufheap.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libsync.so

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# Kernel module loading (resolved dynamically from installed partitions)
AERA_LOAD_VENDOR_BOOT_MODULES         := true
AERA_LOAD_VENDOR_MODULES_EXCLUDE_GKI  := true
# aston is on a 5.15 kernel
AERA_ROOT_MODULE_KERNELS              := 5.15
AERA_LOAD_VENDOR_MODULES := "rproc_qcom_common.ko qcom_q6v5_pas.ko q6_pdr_dlkm.ko q6_notifier_dlkm.ko snd_event_dlkm.ko gpr_dlkm.ko spf_core_dlkm.ko adsp_loader_dlkm.ko q6_dlkm.ko audpkt_ion_dlkm.ko audio_pkt_dlkm.ko audio_prm_dlkm.ko pinctrl_lpi_dlkm.ko swr_dlkm.ko swr_ctrl_dlkm.ko swr_dmic_dlkm.ko swr_haptics_dlkm.ko lpass_cdc_dlkm.ko lpass_cdc_rx_macro_dlkm.ko lpass_cdc_tx_macro_dlkm.ko lpass_cdc_va_macro_dlkm.ko lpass_cdc_wsa_macro_dlkm.ko lpass_cdc_wsa2_macro_dlkm.ko wsa884x_dlkm.ko wcd939x_dlkm.ko wcd939x_slave_dlkm.ko wcd938x_dlkm.ko wcd938x_slave_dlkm.ko mbhc_dlkm.ko hdmi_dlkm.ko stub_dlkm.ko machine_dlkm.ko oplus_audio_aw882xx.ko nvmem_qfprom.ko gpucc-kalama.ko msm_hw_fence.ko sync_fence.ko msm_kgsl.ko msm_drm.ko synaptics_tcm2.ko oplus_bsp_synaptics_tcm2.ko oplus_bsp_tp_notify.ko oplus_bsp_tp_comon.ko oplus_bsp_tp_common.ko oplus_bsp_tp_syna_comnon.ko oplus_bsp_tp_syna_common.ko oplus_bsp_tp_goodix_comnon.ko oplus_bsp_tp_custom.ko oplus_bsp_tp_tcm_S3910.ko oplus_bsp_tp_tcm_oncell.ko oplus_bsp_tp_gt9916.ko oplus_bsp_tp_gt9966.ko oplus_bsp_tp_ft3683g.ko focaltech_ts.ko qcom-hv-haptics.ko oplus_chg.ko oplus_chg_symbol.ko oplus_chg_v2.ko qsee_ipc_irq_bridge.ko smcinvoke_dlkm.ko spcom.ko spss_utils.ko"
AERA_POST_DECRYPT_MODULES := "mhi.ko qrtr.ko qrtr-smd.ko qrtr-mhi.ko mhi_cntrl_qcom.ko cnss_prealloc.ko cnss_nl.ko wlan_firmware_service.ko cnss_plat_ipc_qmi_svc.ko cnss_utils.ko cnss2.ko rfkill.ko cfg80211.ko gsim.ko rmnet_mem.ko ipam.ko qca_cld3_kiwi_v2.ko wlan.ko qca_cld3_wlan.ko"

# Wi-Fi
WPA_SUPPLICANT_VERSION                   := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER              := NL80211
BOARD_HOSTAPD_DRIVER                     := NL80211
WIFI_DRIVER_DEFAULT                      := qca_cld3
WIFI_DRIVER_STATE_CTRL_PARAM             := "/dev/wlan"
WIFI_DRIVER_STATE_ON                     := "ON"
WIFI_DRIVER_STATE_OFF                    := "OFF"
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
