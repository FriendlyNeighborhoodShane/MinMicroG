#!/system/bin/sh
# MinMicroG bootup script

# Wait for bootup
while true; do [ "$(getprop sys.boot_completed)" = "1" ] && break; sleep 5; done;

# Fix GMS permission troubles
apk="/system/priv-app/MicroGGMSCore/MicroGGMSCore.apk";
[ -f "$apk" ] && pm install -r "$apk";

# Grant permissions
npem;
