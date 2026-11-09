#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 AERA Recovery Project contributors
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),aston)

define aston-add-lib
include $$(CLEAR_VARS)
LOCAL_MODULE := $(1)
LOCAL_MODULE_STEM := $(2)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_MULTILIB := 64
LOCAL_STRIP_MODULE := false
LOCAL_CHECK_ELF_FILES := false
LOCAL_MODULE_PATH := $$(TARGET_RECOVERY_ROOT_OUT)/vendor/lib64
LOCAL_PREBUILT_MODULE_FILE := $(3)/$(2).so
LOCAL_REQUIRED_MODULES := $(4)
include $$(BUILD_PREBUILT)
endef

$(eval $(call aston-add-lib,aston_libdrm.recovery,libdrm,$$(TARGET_OUT_VENDOR_SHARED_LIBRARIES),libdrm.vendor))
$(eval $(call aston-add-lib,aston_libsync.recovery,libsync,$$(TARGET_OUT_SHARED_LIBRARIES),libsync))
$(eval $(call aston-add-lib,aston_km_messages.recovery,libkeymaster_messages,$$(TARGET_OUT_VENDOR_SHARED_LIBRARIES),libkeymaster_messages.vendor))
$(eval $(call aston-add-lib,aston_secureclock_v1.recovery,android.hardware.security.secureclock-V1-ndk,$$(TARGET_OUT_VENDOR_SHARED_LIBRARIES),android.hardware.security.secureclock-V1-ndk.vendor))
$(eval $(call aston-add-lib,aston_sharedsecret_v1.recovery,android.hardware.security.sharedsecret-V1-ndk,$$(TARGET_OUT_VENDOR_SHARED_LIBRARIES),android.hardware.security.sharedsecret-V1-ndk.vendor))
$(eval $(call aston-add-lib,aston_rkp_v3_compat.recovery,android.hardware.security.rkp-V3-ndk,$$(TARGET_OUT_SHARED_LIBRARIES)/aston-compat,libaston_rkp_v3_compat))
$(eval $(call aston-add-lib,aston_keymint_v2_compat.recovery,android.hardware.security.keymint-V2-ndk,$$(TARGET_OUT_SHARED_LIBRARIES)/aston-compat,libaston_keymint_v2_compat))
$(eval $(call aston-add-lib,aston_gk10.recovery,android.hardware.gatekeeper@1.0,$$(TARGET_OUT_SHARED_LIBRARIES),android.hardware.gatekeeper@1.0))
$(eval $(call aston-add-lib,aston_km40.recovery,android.hardware.keymaster@4.0,$$(TARGET_OUT_SHARED_LIBRARIES),android.hardware.keymaster@4.0))
$(eval $(call aston-add-lib,aston_km41.recovery,android.hardware.keymaster@4.1,$$(TARGET_OUT_SHARED_LIBRARIES),android.hardware.keymaster@4.1))
$(eval $(call aston-add-lib,aston_hidl_alloc.recovery,android.hidl.allocator@1.0,$$(TARGET_OUT_SHARED_LIBRARIES),android.hidl.allocator@1.0))
$(eval $(call aston-add-lib,aston_hidl_mem.recovery,android.hidl.memory@1.0,$$(TARGET_OUT_SHARED_LIBRARIES),android.hidl.memory@1.0))
$(eval $(call aston-add-lib,aston_hidlmemory.recovery,libhidlmemory,$$(TARGET_OUT_SHARED_LIBRARIES),libhidlmemory))

include $(CLEAR_VARS)
LOCAL_MODULE := aston_vibrator.recovery
LOCAL_MODULE_STEM := vendor.qti.hardware.vibrator.service.oplus
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_STRIP_MODULE := false
LOCAL_CHECK_ELF_FILES := false
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/vendor/bin/hw
LOCAL_PREBUILT_MODULE_FILE := $(TARGET_OUT_VENDOR_EXECUTABLES)/hw/vendor.qti.hardware.vibrator.service.oplus
LOCAL_REQUIRED_MODULES := vendor.qti.hardware.vibrator.service.oplus_aston
include $(BUILD_PREBUILT)

endif
