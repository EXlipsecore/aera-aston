#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

KGSL_DIR=/sys/devices/platform/soc/3d00000.qcom,kgsl-3d0/kgsl/kgsl-3d0

i=0
while [ "$i" -lt 30 ]; do
    [ -e /sys/kernel/boot_adsp/boot ] && break
    sleep 0.1
    i=$((i + 1))
done
[ -e /sys/kernel/boot_adsp/boot ] && echo 1 > /sys/kernel/boot_adsp/boot 2>/dev/null

chmod 0666 /dev/kgsl-3d0 /dev/dma_heap/* 2>/dev/null

# let the gpu clock up instead of sitting at the lowest level
if [ -w "$KGSL_DIR/min_pwrlevel" ]; then
    echo 0 > "$KGSL_DIR/min_pwrlevel" 2>/dev/null
    echo "min_pwrlevel 0" > /tmp/aston-gpu.log
else
    echo "min_pwrlevel not writable" > /tmp/aston-gpu.log
fi
[ -w "$KGSL_DIR/max_pwrlevel" ] && echo 0 > "$KGSL_DIR/max_pwrlevel" 2>/dev/null

{
    cat "$KGSL_DIR/gpu_model" 2>/dev/null
    cat "$KGSL_DIR/gpu_available_frequencies" 2>/dev/null
} >> /tmp/aston-gpu.log 2>&1

chmod 0755 /vendor/bin/hw/vendor.qti.hardware.vibrator.service.oplus 2>/dev/null
start vibrator
start aston-cpu-sensor

[ -e /sys/class/power_supply/usb/otg_switch ] && echo 1 > /sys/class/power_supply/usb/otg_switch 2>/dev/null
[ -e /proc/touchpanel/game_switch_enable ] && echo 1 > /proc/touchpanel/game_switch_enable 2>/dev/null
exit 0
