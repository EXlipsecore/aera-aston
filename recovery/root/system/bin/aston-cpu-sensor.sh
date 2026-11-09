#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

for z in /sys/class/thermal/thermal_zone*; do
    [ -r "$z/type" ] || continue
    t="$(cat "$z/type" 2>/dev/null)"
    case "$t" in
        cpuss-0*|cpu-1-0*|cpu-0-0*)
            ln -sfn "$z/temp" /tmp/aston-cpu-temp
            break
            ;;
    esac
done
exit 0
