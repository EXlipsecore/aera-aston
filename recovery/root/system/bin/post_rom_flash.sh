#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

rm -rf /tmp/aera_vab_ota /tmp/.aston_misc_4k 2>/dev/null

MISC_DEV=/dev/block/by-name/misc
[ -b "$MISC_DEV" ] || MISC_DEV=/dev/block/bootdevice/by-name/misc
if [ -b "$MISC_DEV" ]; then
    if dd if="$MISC_DEV" of=/tmp/.aston_misc_4k bs=4096 count=1 2>/dev/null; then
        if head -c 1088 /tmp/.aston_misc_4k 2>/dev/null | tr '\0' '\n' | grep -q -- '--wipe_data'; then
            dd if=/dev/zero of=/tmp/.aston_misc_4k bs=1088 count=1 conv=notrunc 2>/dev/null
            dd if=/tmp/.aston_misc_4k of="$MISC_DEV" bs=4096 count=1 2>/dev/null
            sync
        fi
        rm -f /tmp/.aston_misc_4k 2>/dev/null
    fi
fi

CUR_SL="$(getprop ro.boot.slot_suffix)"
CUR_NUM="$(/system/bin/bootctl get-current-slot 2>/dev/null)"
ACT_NUM="$(/system/bin/bootctl get-active-boot-slot 2>/dev/null)"

if [ -n "$CUR_SL" ] && [ -n "$CUR_NUM" ] && [ -n "$ACT_NUM" ] && [ "$CUR_NUM" != "$ACT_NUM" ]; then
    MNT_META=0
    META_DEV=/dev/block/by-name/metadata
    [ -b "$META_DEV" ] || META_DEV=/dev/block/bootdevice/by-name/metadata
    if ! grep -q " /metadata " /proc/mounts 2>/dev/null; then
        mkdir -p /metadata
        if mount -t f2fs -o noatime,nosuid,nodev,discard "$META_DEV" /metadata 2>/dev/null || \
           mount "$META_DEV" /metadata 2>/dev/null; then
            MNT_META=1
        fi
    fi

    if [ -f /metadata/ota/state ] && [ -f /metadata/ota/snapshot-boot ]; then
        BOOT_SL="$(cat /metadata/ota/snapshot-boot 2>/dev/null)"
        if [ "$BOOT_SL" = "$CUR_SL" ]; then
            printf '1' > /metadata/ota/allow-forward-merge 2>/dev/null
            chown 0:1000 /metadata/ota/allow-forward-merge 2>/dev/null
            chmod 0644 /metadata/ota/allow-forward-merge 2>/dev/null
            chcon u:object_r:ota_metadata_file:s0 /metadata/ota/allow-forward-merge 2>/dev/null
            if [ -f /metadata/gsi/ota/lp_metadata ]; then
                /system/bin/resetprop fox_block_operations_pending_reboot blocking 2>/dev/null
                setprop fox_block_operations_pending_reboot blocking 2>/dev/null
            else
                cp -a /metadata/ota /tmp/aera_vab_ota 2>/dev/null
            fi
            sync
        fi
    fi

    [ "$MNT_META" = "1" ] && umount /metadata 2>/dev/null
fi

setprop ctl.start snapuserd 2>/dev/null
exit 0
