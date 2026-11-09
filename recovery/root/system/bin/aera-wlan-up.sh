#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

mkdir -p /tmp/recovery/sockets
for n in /sys/devices/platform/soc/*.qcom,cnss*/fs_ready /sys/kernel/cnss/fs_ready; do
    [ -e "$n" ] || continue
    chmod 0222 "$n" 2>/dev/null
    echo 1 > "$n" 2>/dev/null
done

i=0
while [ "$i" -lt 25 ]; do
    [ -e /sys/class/net/wlan0 ] && break
    sleep 1
    i=$((i + 1))
done

[ -e /sys/class/net/wlan0 ] && setprop wifi.driver.ready true
exit 0
