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

## Audio

Kernel modules and the stock AGM/PAL stack are wired up. The plugin bridge
is not ported yet, so there is no sound from plugins.

```
adb shell dmesg | grep -A4 "ALSA device list"
adb shell logcat -s AERAAudio
```

`audio/README.md` has the full chain and the failure modes.

## GPU

```
adb shell /system/bin/aera-gpu-probe
```

Prints the GL renderer. `Adreno (TM) 740` means the driver is fine and the
slowdown is power or refresh config.

## Bootloader

This tree does not create, patch or inject super partitions. To lock the
bootloader, flash complete stock firmware for your model first, boot once,
then `fastboot flashing lock`. Locking over a partially flashed super needs
EDL to recover.
