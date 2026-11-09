# AERA device tree - OnePlus 12R / Ace 3

Recovery device tree for SM8550 (Kalama).

## Devices

| Model | Codename | Region |
| --- | --- | --- |
| CPH2585 | aston (OP5D35L1) | India |
| CPH2609 / CPH2609EEA | aston (OP5D35L1) | Global / EU |
| CPH2611 | aston (OP5D35L1) | North America |
| PJE110 | astonc (OP5CF9L1) | China |

## Working

Display 1264x2780 @ 120 Hz, Synaptics S3910 touch, FBEv2 decryption
(Android 14-17), flashing stock OxygenOS / ColorOS and custom ROMs, VAB OTA
sideload, ADB, MTP, USB-OTG, fastbootd, Wi-Fi (WCN6855 kiwi_v2), haptics,
FRP wipe, ABL preservation, F2FS compression on Format Data.

## Build

```
mkdir -p ~/android/AERA_16.0 && cd ~/android/AERA_16.0
repo init -u https://github.com/AERA-Recovery/android_manifest.git -b aera-16.0
repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc)
```

```
git clone -b aera-16.0 https://github.com/EXlipsecore/aera-aston.git \
  device/oneplus/aston
source build/envsetup.sh
lunch twrp_aston-bp2a-eng
mka adbd recoveryimage
```
