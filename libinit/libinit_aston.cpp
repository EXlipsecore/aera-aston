/*
 * Copyright (C) 2026 The LineageOS Project
 * Copyright (C) 2026 AERA Recovery Project contributors
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/parseint.h>
#include <android-base/properties.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <cstring>
#include <string>
#include <vector>

#include "vendor_init.h"

using android::base::GetProperty;
using android::base::ParseInt;

namespace {

constexpr const char* kTargetDevices =
    "aston,astonc,OP5D35L1,OP5CF9L1,CPH2585,CPH2609,CPH2609EEA,CPH2611,PJE110,ossi,qssi";

void OverrideProperty(const char* key, const char* value) {
    size_t len = strlen(value);
    if (len >= PROP_VALUE_MAX) {
        len = PROP_VALUE_MAX - 1;
    }

    auto* pi = const_cast<prop_info*>(__system_property_find(key));
    if (pi != nullptr) {
        __system_property_update(pi, value, len);
    } else {
        __system_property_add(key, strlen(key), value, len);
    }
}

void SetVariantProps(const char* device, const char* odm_device,
                     const char* model, const char* name) {
    const std::vector<std::string> partitions = {
        "", "bootimage.", "odm.", "product.",
        "system.", "system_ext.", "vendor.", "vendor_dlkm.",
    };

    for (const auto& p : partitions) {
        OverrideProperty(("ro.product." + p + "device").c_str(),
                         p == "odm." ? odm_device : device);
        OverrideProperty(("ro.product." + p + "model").c_str(), model);
        OverrideProperty(("ro.product." + p + "name").c_str(), name);
        OverrideProperty(("ro.product." + p + "brand").c_str(), "OnePlus");
        OverrideProperty(("ro.product." + p + "manufacturer").c_str(), "OnePlus");
    }

    OverrideProperty("ro.build.product", device);
    OverrideProperty("ro.product.device", device);
    OverrideProperty("ro.product.model", model);
    OverrideProperty("ro.product.name", name);
    OverrideProperty("ro.twrp.target.devices", kTargetDevices);
    OverrideProperty("ro.ota.allow_downgrade", "true");
}

}  // namespace

void vendor_load_properties() {
    int prjname = 0;
    int rf_version = 0;
    ParseInt(GetProperty("ro.boot.prjname", "0"), &prjname);
    ParseInt(GetProperty("ro.boot.rf_version", "0"), &rf_version);

    if (prjname == 23801) {
        SetVariantProps("astonc", "OP5CF9L1", "PJE110", "PJE110");
    } else if (rf_version == 21) {
        SetVariantProps("aston", "OP5D35L1", "CPH2609", "CPH2609");
    } else if (rf_version == 22) {
        SetVariantProps("aston", "OP5D35L1", "CPH2609", "CPH2609EEA");
    } else if (rf_version == 23) {
        SetVariantProps("aston", "OP5D35L1", "CPH2611", "CPH2611");
    } else {
        SetVariantProps("aston", "OP5D35L1", "CPH2585", "CPH2585");
    }
}
