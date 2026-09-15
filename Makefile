obj-m := mk_arcade_joystick_rpi.o
KVERSION := $(shell uname -r)

# Detect the Pi model directly, since the kernel version string (-v7/-v8/-2712)
# no longer reliably distinguishes Pi 2/3/4/5 once you're on a 64-bit kernel.
PI_MODEL := $(shell tr -d '\0' < /proc/device-tree/model 2>/dev/null)

ifneq (,$(findstring Raspberry Pi 5,$(PI_MODEL)))
CFLAGS_mk_arcade_joystick_rpi.o := -DRPI5
else ifneq (,$(findstring Raspberry Pi 4,$(PI_MODEL)))
CFLAGS_mk_arcade_joystick_rpi.o := -DRPI4
else ifneq (,$(findstring Raspberry Pi 3,$(PI_MODEL))$(findstring Raspberry Pi 2,$(PI_MODEL)))
CFLAGS_mk_arcade_joystick_rpi.o := -DRPI2
endif

# Fallback for builds where /proc/device-tree/model isn't available
# (e.g. cross-compiling off-device) - only reliable for 32-bit kernels.
ifeq ($(PI_MODEL),)
ifneq (,$(findstring -v7,$(KVERSION)))
CFLAGS_mk_arcade_joystick_rpi.o := -DRPI2
endif
endif

all:
	$(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
clean:
	$(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) clean
