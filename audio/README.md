# Audio

Recovery audio via the stock Qualcomm AGM/PAL stack.

Nothing proprietary is shipped in this tree. The daemons and AGM libraries are
read from the installed vendor partition at runtime.

## How it fits together

```
aston-audio-bootstrap        mounts stock vendor/system/odm/dsp/modem read-only
                             at /mnt/aera-stock, exposes abi shims, then
                             starts the services below in order

aera-audio-relay              symlinks the stock daemons to their aera-* names
                               /vendor/bin/adsprpcd
                                 -> /vendor/bin/aera-audioadsprpcd
                               /vendor/bin/pd-mapper
                                 -> /vendor/bin/aera-pd-mapper
                               /vendor/bin/hw/vendor.qti.hardware.dsp@1.0-service
                                 -> /vendor/bin/aera-dspservice

aera-pd-mapper                registers protection domains from
                              /vendor/firmware_mnt/image

aera-dspservice               vendor.qti.hardware.dsp.IDspService

aera-audioadsprpcd            audiopd. creates the APM endpoint, must be up
                              before the machine driver probes

aera-audio-service            dlopen's libagmipcservice.so and
                              libpalipcservice.so from /mnt/aera-stock/vendor/lib64
                              and registers
                                vendor.qti.hardware.agm.IAGM/default
                                vendor.qti.hardware.pal.IPAL/default
```

## Kernel side

`AERA_LOAD_VENDOR_MODULES` in `BoardConfig.mk` carries the full SM8550 audio
chain so the machine driver and codec macros can bind:

`machine_dlkm`, `lpass_cdc_dlkm`, `lpass_cdc_{rx,tx,va,wsa,wsa2}_macro_dlkm`,
`wsa884x_dlkm`, `swr_dlkm`, `swr_ctrl_dlkm`, `swr_dmic_dlkm`,
`swr_haptics_dlkm`, `q6_dlkm`, `audpkt_ion_dlkm`, `audio_pkt_dlkm`,
`audio_prm_dlkm`, `mbhc_dlkm`, `stub_dlkm`, `hdmi_dlkm`,
`oplus_audio_aw882xx`.

Speaker output needs `wsa884x_dlkm` (the amps) and `oplus_audio_aw882xx`
(the smart PA driver) both loaded, plus valid `/vendor/etc/acdbdata`.

## Checking it

Kernel side first:

```
adb shell dmesg | grep -A4 "ALSA device list"
```

`No soundcards found.` means `machine_dlkm` or the codec macros are still not
binding. If a card is listed the kernel side is done.

Then:

```
adb shell cat /proc/asound/cards
adb shell ls -l /dev/snd/
adb shell getprop init.svc.aera-audio-bootstrap
adb shell logcat -s AERAAudio
```

## Expected failure modes

| Symptom | Cause |
| --- | --- |
| `could not mount stock vendor` | vendor did not map, check the slot |
| `daemon links failed` | a stock daemon is missing from this OxygenOS build |
| `machine sound card did not register` | modules not loaded, check `dmesg` |
| `aston stock AGM load failed` | `libagmipcservice.so` not in stock `vendor/lib64` |
| daemons restart-looping | binder shim not mounted, check `/vendor/aera-audio-abi` |

## Verified against aston trees

Checked LineageOS/android_device_oneplus_aston,
OnePlus12R-development/android_device_oneplus_aston and
TheMuppets/proprietary_vendor_oneplus_aston. None of them ship recovery audio,
so there is no reference configuration to copy. What they do confirm:

- The ADSP firmware directory on aston is `/odm/lib/rfsa/adsp`, carrying
  `libtfadsp_sb4_0_rx.so` and `libtfadsp_sb4_0_tx.so`.
- That path is exactly what Qualcomm's `adsprpcd` looks for, so routing it
  through the stock vendor mount is correct.
- aston super is 16642998272 bytes, matching `BOARD_SUPER_PARTITION_SIZE` here.

## Still open

The plugin bridge (`aera_audio_bridge.cpp` in the OnePlus 13 tree) is not
ported. That is the socket the browser and media UIDs connect to. Without it
the AGM backend can register but nothing routes audio into it.

Its `agmplay -i` device name is `MI2S-LPAIF-RX-SECONDARY` on the OnePlus 13.
That value has to be read from aston's own `/vendor/etc/mixer_paths*.xml`
before the bridge is wired up, otherwise playback fails without an error.
