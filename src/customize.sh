#!/system/bin/sh

SKIPUNZIP=1;
export BOOTMODE MODPATH TMPDIR ZIPFILE ARCH IS64BIT API;
export MAGISK_VER MAGISK_VER_CODE;
export KSU KSU_VER KSU_VER_CODE KSU_KERNEL_VER_CODE;

unzip -qoj "$ZIPFILE" "META-INF/com/google/android/update-binary" -d "$TMPDIR/";
"$TMPDIR/update-binary" "" "" "$ZIPFILE";
