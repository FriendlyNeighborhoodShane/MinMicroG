#!/system/bin/sh
export KSU KSU_VER KSU_VER_CODE MAGISK_VER MAGISK_VER_CODE BOOTMODE MODPATH TMPDIR ZIPFILE ARCH IS64BIT API;
SKIPUNZIP=1;
modname="MinMicroG";
mkdir -p "$TMPDIR/$modname";
unzip -qj "$ZIPFILE" defconf META-INF/com/google/android/update-binary -d "$TMPDIR/$modname";
sh "$TMPDIR/$modname/update-binary" '' '' "$ZIPFILE";
