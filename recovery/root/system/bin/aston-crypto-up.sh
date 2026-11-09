#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

[ "$(getprop crypto.ready)" = "1" ] && exit 0
mkdir /tmp/.aston_crypto_lock 2>/dev/null || exit 0

[ "$(getprop aston.qsee.ready)" = "1" ] || start aston-qsee-up

SL="$(getprop ro.boot.slot_suffix)"
RP=/system/bin/resetprop
[ -x "$RP" ] || RP=resetprop

REL=""; RELN=0; SPL=""; SPLN=0; VSPL=""; VSPLN=0
if [ "$(getprop aston.vab.unmerged)" != "1" ]; then
    mkdir -p /mnt/spl_tmp
    for s in "$SL" _a _b; do
        [ -n "$s" ] || continue
        for p in system vendor odm my_manifest; do
            B="/dev/block/mapper/${p}${s}"
            [ -b "$B" ] || continue
            if mount -r "$B" /mnt/spl_tmp 2>/dev/null || \
               mount -t erofs -r "$B" /mnt/spl_tmp 2>/dev/null || \
               mount -t ext4 -r "$B" /mnt/spl_tmp 2>/dev/null; then
                for f in /mnt/spl_tmp/build.prop /mnt/spl_tmp/system/build.prop /mnt/spl_tmp/etc/build.prop; do
                    [ -f "$f" ] || continue
                    v="$(sed -n 's/^ro\.build\.version\.release=//p' "$f" | tail -n 1)"
                    rn="${v%%.*}"
                    case "$rn" in
                        ''|*[!0-9]*) ;;
                        *) [ "${rn:-0}" -gt "$RELN" ] 2>/dev/null && { REL="$v"; RELN="$rn"; } ;;
                    esac
                    v="$(sed -n 's/^ro\.build\.version\.security_patch=//p' "$f" | tail -n 1)"
                    vn="$(printf '%s' "$v" | tr -d '-')"
                    [ "${vn:-0}" -gt "$SPLN" ] 2>/dev/null && { SPL="$v"; SPLN="$vn"; }
                    v="$(sed -n 's/^ro\.vendor\.build\.security_patch=//p' "$f" | tail -n 1)"
                    vn="$(printf '%s' "$v" | tr -d '-')"
                    [ "${vn:-0}" -gt "$VSPLN" ] 2>/dev/null && { VSPL="$v"; VSPLN="$vn"; }
                done
                umount /mnt/spl_tmp 2>/dev/null || umount -l /mnt/spl_tmp 2>/dev/null
            fi
        done
    done
    rmdir /mnt/spl_tmp 2>/dev/null
fi

for s in _a _b; do
    for vp in vbmeta vbmeta_system vbmeta_vendor; do
        VB="/dev/block/bootdevice/by-name/${vp}${s}"
        [ -b "$VB" ] || VB="/dev/block/by-name/${vp}${s}"
        [ -b "$VB" ] || continue
        for v in $(dd if="$VB" bs=65536 count=1 2>/dev/null | strings 2>/dev/null | grep -E '^202[4-9]-[01][0-9]-[0-3][0-9]$'); do
            vn="$(printf '%s' "$v" | tr -d '-')"
            [ "${vn:-0}" -gt "$SPLN" ] 2>/dev/null && { SPL="$v"; SPLN="$vn"; }
            [ "${vn:-0}" -gt "$VSPLN" ] 2>/dev/null && { VSPL="$v"; VSPLN="$vn"; }
        done
    done
done

if command -v "$RP" >/dev/null 2>&1; then
    [ -n "$REL" ] && "$RP" ro.build.version.release "$REL"
    [ -n "$SPL" ] && "$RP" ro.build.version.security_patch "$SPL"
    [ -n "$VSPL" ] && "$RP" ro.vendor.build.security_patch "$VSPL"
fi

i=0
while [ "$i" -lt 50 ]; do
    [ "$(getprop vendor.sys.listeners.registered)" = "true" ] && break
    [ "$(getprop aston.qsee.ready)" = "1" ] && break
    sleep 0.1
    i=$((i + 1))
done

start vendor.keymint-qti
setprop crypto.ready 1
exit 0
