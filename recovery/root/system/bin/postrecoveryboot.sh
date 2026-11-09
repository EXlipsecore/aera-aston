#!/system/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

if [ -d /data/media/0 ] && [ ! -f /data/media/0/AERA/.aston_ui_v2 ]; then
    mkdir -p /data/media/0/AERA /data/recovery
    if [ -f /data/media/0/AERA/preferences.conf ]; then
        sed -i 's/^interface_size=1$/interface_size=2/' /data/media/0/AERA/preferences.conf
    else
        printf 'interface_size=2\n' > /data/media/0/AERA/preferences.conf
    fi
    if [ -f /data/media/0/AERA/early-ui.conf ]; then
        sed -i 's/^interface_size=1$/interface_size=2/' /data/media/0/AERA/early-ui.conf
    fi
    : > /data/media/0/AERA/.aston_ui_v2
fi
exit 0
