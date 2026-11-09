# GPU

Adreno 740 blobs for SM8550 live in `recovery/root/vendor/lib64/` and
`recovery/root/vendor/lib64/egl/`.

`egl_probe.cpp` builds `aera-gpu-probe`, which checks whether the Adreno path
actually works or whether the UI has fallen back to software rendering.

## Why

The AERA UI logs uneven frame rates on aston, for example:

```
active animation submitted 87.8 fps
active animation submitted 18.3 fps
active animation submitted 32.6 fps
```

on a panel that is running 1264x2780 @ 120 Hz. That can be either the GPU
being held at a low power level, or the EGL subdriver not loading at all.
Guessing between the two wastes a lot of time, so the probe settles it.

## Usage

```
adb shell /system/bin/aera-gpu-probe
```

| Output | Meaning |
| --- | --- |
| `HARDWARE (Adreno) path active` and `PASS` | Driver stack is fine, look at power and refresh |
| `SOFTWARE FALLBACK` | Adreno blobs or KGSL failed, check `dmesg \| grep kgsl` |
| `no EGL config` | EGL came up but GLES2 is missing, blobs incomplete |
| `cannot dlopen libEGL_adreno.so` | Blobs missing from the ramdisk |

The `GL renderer` line should contain `Adreno (TM) 740`. The fps figure for a
256x256 pbuffer should be well above 120 on this chip. Numbers in the tens
mean the GPU is throttled.

## Power level

`runatboot.sh` sets `min_pwrlevel` to 0 on the KGSL node so the GPU can clock
up. Before, nothing managed that node and the kernel log had an `avc: denied`
on it.

It also writes `gpu_model` and `gpu_available_frequencies` to
`/tmp/aston-gpu.log` on each boot.

## Refresh rate

`system.prop` sets `ro.surface_flinger.game_default_frame_rate_override=120`
and `vendor.gralloc.enable_snapalloc=true`. The frame rate override has to be
120 on this panel, a value of 60 fights the hardware mode.

Check with:

```
adb shell dmesg | grep -i "display mode"
adb shell getprop ro.surface_flinger.game_default_frame_rate_override
adb shell cat /tmp/aston-gpu.log
```

## Firmware

KGSL firmware for aston lives in `recovery/root/lib/firmware/` and
`recovery/root/vendor/firmware/`:

```
a740_sqe.fw
a740_zap.b00 a740_zap.b01 a740_zap.b02 a740_zap.elf a740_zap.mbn a740_zap.mdt
gmu_gen70200.bin
```

These are Adreno 740 / Gen7 files. The `gen80000_*` images from the OnePlus 13
are Adreno 830 / Gen8 and will not load on SM8550.
