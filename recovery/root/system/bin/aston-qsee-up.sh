#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

[ "$(getprop aston.qsee.ready)" = "1" ] && exit 0

SL="$(getprop ro.boot.slot_suffix)"
if [ ! -d /firmware/image ]; then
    mkdir -p /firmware
    mount -t vfat -o ro,shortname=lower,uid=0,gid=1000,dmask=227,fmask=337,context=u:object_r:aston_firmware_file:s0 \
        "/dev/block/bootdevice/by-name/modem${SL}" /firmware 2>/dev/null || \
    mount -t vfat -o ro,shortname=lower,uid=0,gid=1000,dmask=227,fmask=337 \
        "/dev/block/bootdevice/by-name/modem${SL}" /firmware 2>/dev/null
fi

rm -f /vendor/firmware_mnt 2>/dev/null
ln -sfn /firmware /vendor/firmware_mnt
mkdir -p /lib/firmware/kiwi /vendor/firmware/kiwi

for f in /firmware/image/*; do
    [ -e "$f" ] || continue
    bn="${f##*/}"
    [ "$bn" = "kiwi" ] && continue
    [ -e "/lib/firmware/$bn" ] || ln -sfn "$f" "/lib/firmware/$bn"
    [ -e "/vendor/firmware/$bn" ] || ln -sfn "$f" "/vendor/firmware/$bn"
done

for f in /firmware/image/kiwi/* /firmware/image/amss*.bin /firmware/image/m3.bin; do
    [ -e "$f" ] || continue
    bn="${f##*/}"
    [ -e "/lib/firmware/kiwi/$bn" ] || ln -sfn "$f" "/lib/firmware/kiwi/$bn"
    [ -e "/vendor/firmware/kiwi/$bn" ] || ln -sfn "$f" "/vendor/firmware/kiwi/$bn"
done

if ! grep -q " /mnt/vendor/persist " /proc/mounts 2>/dev/null; then
    mkdir -p /mnt/vendor/persist
    if ! mount -t ext4 -o ro /dev/block/bootdevice/by-name/persist /mnt/vendor/persist 2>/dev/null; then
        mkdir -p /tmp/persist/data
        mount -o bind /tmp/persist /mnt/vendor/persist 2>/dev/null
    fi
fi

i=0
while [ "$i" -lt 30 ]; do
    if [ -e /dev/ufs-bsg0 ] || [ -e /dev/bsg/ufs-bsg0 ]; then
        [ -e /dev/0:0:0:49476 ] && [ -c /dev/qseecom ] && break
    fi
    sleep 0.1
    i=$((i + 1))
done

[ -e /dev/ufs-bsg0 ] || { [ -e /dev/bsg/ufs-bsg0 ] && ln -sf /dev/bsg/ufs-bsg0 /dev/ufs-bsg0; }
[ -e /dev/0:0:0:49476 ] || { [ -e /dev/bsg/0:0:0:49476 ] && ln -sf /dev/bsg/0:0:0:49476 /dev/0:0:0:49476; }

chown system:system /dev/0:0:0:49476 /dev/ufs-bsg0 /dev/ion /dev/membuf /dev/spcom /dev/spss_utils /dev/dma_heap/* 2>/dev/null
chmod 0600 /dev/0:0:0:49476 2>/dev/null
chmod 0660 /dev/ufs-bsg0 2>/dev/null
chmod 0666 /dev/dma_heap/* 2>/dev/null
chown system:drmrpc /dev/qseecom /dev/smcinvoke /dev/qce /dev/qsee_ipc_irq_spss 2>/dev/null
chmod 0660 /dev/qseecom /dev/smcinvoke /dev/qce /dev/qsee_ipc_irq_spss 2>/dev/null

start vendor.qseecomd
i=0
while [ "$i" -lt 50 ]; do
    [ "$(getprop vendor.sys.listeners.registered)" = "true" ] && break
    sleep 0.1
    i=$((i + 1))
done

start qseecom-service
start gatekeeper-1-0
setprop aston.qsee.ready 1
exit 0
