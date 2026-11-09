#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 AERA Recovery Project contributors
#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration
$(call inherit-product, device/oneplus/aston/device.mk)

PRODUCT_DEVICE := aston
PRODUCT_NAME := twrp_aston
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := OnePlus 12R
PRODUCT_MANUFACTURER := OnePlus

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

AERA_STATUS_ICONS_ALIGN := center
