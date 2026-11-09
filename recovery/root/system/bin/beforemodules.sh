#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

for w in /sys/bus/platform/drivers/msm_watchdog/*/disable /sys/devices/platform/soc/*.qcom,wdt/disable; do
    [ -w "$w" ] && printf '1' > "$w" 2>/dev/null
done
[ -w /proc/oplus_init_watchdog/kick ] && printf 'disable' > /proc/oplus_init_watchdog/kick 2>/dev/null
[ -w /proc/phoenix ] && printf 'PHOENIX_BOOT_COMPLETED' > /proc/phoenix 2>/dev/null


PRJ="$(getprop ro.boot.prjname)"
case "$PRJ" in
    23801) WPRJ="23801" ;;
    *)     WPRJ="23861" ;;
esac

mkdir -p /lib/firmware/kiwi /lib/firmware/tp \
    /odm/firmware/tp /vendor/firmware/kiwi /vendor/firmware/tp \
    /vendor/firmware/wlan/qca_cld/kiwi_v2 \
    /odm/etc/wifi /odm/vendor/etc/wifi /tmp/recovery/sockets

rm -rf /lib/firmware/wlan 2>/dev/null
ln -sfn /vendor/firmware/wlan /lib/firmware/wlan
ln -sfn 23801 /odm/firmware/tp/23861
ln -sfn 23801 /vendor/firmware/tp/23861
ln -sfn 23801 /lib/firmware/tp/23861
ln -sfn "/odm/etc/wifi/kiwi_$WPRJ" /odm/etc/wifi/kiwi

for f in "/odm/etc/wifi/kiwi_$WPRJ/"*; do
    [ -e "$f" ] || continue
    bn="${f##*/}"
    ln -sfn "$f" "/lib/firmware/kiwi/$bn"
    ln -sfn "$f" "/vendor/firmware/kiwi/$bn"
done

cp -f "/odm/vendor/etc/wifi_$WPRJ/WCNSS_qcom_cfg.ini" /odm/vendor/etc/wifi/WCNSS_qcom_cfg.ini 2>/dev/null
cp -f "/odm/vendor/etc/wifi_$WPRJ/WCNSS_qcom_cfg.ini" /vendor/etc/wifi/WCNSS_qcom_cfg.ini 2>/dev/null
cp -f "/odm/vendor/etc/wifi_$WPRJ/WCNSS_qcom_cfg.ini" /vendor/firmware/wlan/qca_cld/WCNSS_qcom_cfg.ini 2>/dev/null
cp -f "/odm/vendor/etc/wifi_$WPRJ/WCNSS_qcom_cfg.ini" /vendor/firmware/wlan/qca_cld/kiwi_v2/WCNSS_qcom_cfg.ini 2>/dev/null
exit 0
