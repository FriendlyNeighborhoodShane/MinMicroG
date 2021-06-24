# Functions for use by defconfs

# Process user confs
user_conf() {

  for file in "$(dirname "$0")/mmg-conf.txt" "$(dirname "$zipfile")/mmg-conf.txt" "$moddir/mmg-conf.txt" "/data/adb/mmg-conf.txt"; do
    [ -f "$file" ] && {
      ui_print " "; ui_print "Processing user config $file...";
      includelist="$(sed -e 's|\#.*||g' -e 's|[^a-zA-Z0-9._-]| |g' "$file")";
      break;
    }
  done;
  [ "$includelist" ] && {
    new_stuff="";
    new_stuff_arch="";
    new_stuff_sdk="";
    new_stuff_arch_sdk="";
    for include in $includelist; do
      log "Including keyword $include";
      new_stuff="$new_stuff $(echo "$stuff" | grep -oi "[ ]*[^ ]*$include[^ ]*[ ]*")";
      new_stuff_arch="$new_stuff_arch $(echo "$stuff_arch" | grep -oi "[ ]*[^ ]*$include[^ ]*[ ]*")";
      new_stuff_sdk="$new_stuff_sdk $(echo "$stuff_sdk" | grep -oi "[ ]*[^ ]*$include[^ ]*[ ]*")";
      new_stuff_arch_sdk="$new_stuff_arch_sdk $(echo "$stuff_arch_sdk" | grep -oi "[ ]*[^ ]*$include[^ ]*[ ]*")";
    done;
    stuff="$new_stuff";
    stuff_arch="$new_stuff_arch";
    stuff_sdk="$new_stuff_sdk";
    stuff_arch_sdk="$new_stuff_arch_sdk";
  }
  [ "$includelist" ] && {
    stuff="$(echo "$stuff" | sed 's| |\n|g' | tr -s '\n' | sort -u | sed 's|^|  |g')
";
    stuff_arch="$(echo "$stuff_arch" | sed 's| |\n|g' | tr -s '\n' | sort -u | sed 's|^|  |g')
";
    stuff_sdk="$(echo "$stuff_sdk" | sed 's| |\n|g' | tr -s '\n' | sort -u | sed 's|^|  |g')
";
    stuff_arch_sdk="$(echo "$stuff_arch_sdk" | sed 's| |\n|g' | tr -s '\n' | sort -u | sed 's|^|  |g')
";
  }

  [ "$stuff" ] || [ "$stuff_arch" ] || [ "$stuff_sdk" ] || [ "$stuff_arch_sdk" ] || abort "Nothing left to install after config";

}

# Cleanup stuff that might conflict
microg_cleanup() {

  if echo "$stuff" | grep -q "MicroG"; then
    ui_print " ";
    ui_print "Doing MicroG preparations...";
    if [ "$bootmode" != "true" ]; then
      # Kanged from NanoDroid
      # Thanks Setialpha
      cleanup_folders="BlankStore GmsCore GmsCore_update GmsCoreSetupPrebuilt GoogleServicesFramework GsfProxy Phonesky PlayStore PrebuiltGmsCorePi PrebuiltGmsCorePix PrebuiltGmsCore Vending";
      cleanup_packages="com.android.vending com.google.android.feedback com.google.android.gms com.google.android.gsf com.google.android.gsf.login com.mgoogle.android.gms";
      for app in $cleanup_folders; do
        for file in /data/dalvik-cache/*/system"@priv-app@$app"[@\.]*@classes.* /data/dalvik-cache/*/system"@app@$app"[@\.]*@classes.*; do
          [ -e "$file" ] && { log "PREPPER: Removing $file"; rm -rf "$file"; }
        done;
      done;
      if [ -f "$mark_file" ]; then
        log "PREPPER: This is an update flash";
      elif [ -f "$root/system/etc/.mmg" ]; then
        log "PREPPER: This is an update flash";
      else
        log "PREPPER: Doing the clean install treatment";
        for app in $cleanup_packages; do
          for file in "/data/data/$app" "/data/user/*/$app" "/data/user_de/*/$app" "/data/app/$app"-* "/mnt/asec/$app"-* "/data/media/0/Android/data/$app"; do
            [ -e "$file" ] && { log "PREPPER: Removing $file"; rm -rf "$file"; }
          done;
        done;
        for file in /data/system/users/*/runtime-permissions.xml; do
          [ -e "$file" ] && { log "PREPPER: Removing $file"; rm -rf "$file"; }
        done;
        if [ -f /data/system/packages.list ]; then
          for app in $cleanup_packages; do
            if grep -q "$app" "/data/system/packages.list"; then
              log "PREPPER: de-registering app: $app";
              sed -i "s/.*${app}.*//g" /data/system/packages.list;
            fi;
          done;
        fi;
        if command -v "sqlite3" >/dev/null; then
          find /data/system* -type f -name "accounts*db" 2>/dev/null | while read -r database; do
            log "PREPPER: deleting Google Accounts from $database";
            sqlite3 "$database" "DELETE FROM accounts WHERE type='com.google';";
          done
        else
          log "PREPPER: sqlite3 not found";
        fi;
      fi;
    fi;
  fi;

}

# Generate and install an addon.d script
addon_install() {

  [ "$magisk" = "no" ] || return 0;

  log " ";
  log "POST-INSTALL: Installing addon.d script";

  addond="$addond_file";
  mkdir -p "$(dirname "$root/$addond")";
  touch "$root/$addond";
  perm 0 0 0755 0644 "$(dirname "$root/$addond")";
  chcon -hR 'u:object_r:system_file:s0' "$(dirname "$root/$addond")";

  cat << EOF > "$root/$addond";
#!/sbin/sh
#
# MinMicroG addon.d
#
# ADDOND_VERSION=2

save_files() {
cat <<EOL
$(echo "$stuff" "$stuff_arch" "$stuff_sdk" "$stuff_arch_sdk" "$addond_file" "$init_file" "$mark_file" | sed 's| |\n|g' | sort -u | tr -s '\n')

EOL
}

delete_files() {
cat <<EOL
$(echo "$stuff_debloat" | sed 's| |\n|g' | sort -u | tr -s '\n')

EOL
}

EOF

  cat << 'EOF' >> "$root/$addond";
log() { echo "$1"; }

abort() {
  log " ";
  log "!!! ERROR: $1";
  exit 1;
}

log " ";
log "=== MinMicroG addon.d script ===";

if [ -f "/tmp/backuptool.functions" ]; then
  . "/tmp/backuptool.functions" || abort "could not source addon.d helper";
elif [ -f "/postinstall/tmp/backuptool.functions" ]; then
  . "/postinstall/tmp/backuptool.functions" || abort "could not source addon.d helper";
else
  abort "could not find addon.d helper"
fi;

[ -f "$S/build.prop" ] || abort "could not find a ROM in $S";
sdk="$(grep ro.build.version.sdk "$S/build.prop" | head -n1 | cut -d= -f2)";
[ "$sdk" ] && [ "$sdk" -gt "0" ] || abort "could not find SDK";

translate_path() {
  while read -r entry; do
    if [ "$sdk" -lt 21 ]; then
      [ "$(basename "$(dirname "$entry")").apk" = "$(basename "$entry")" ] && entry="$(dirname "$(dirname "$entry")")/$(basename "$entry")";
    fi;
    [ "$(basename "$(dirname "$entry")").apk" = "$(basename "$entry")" ] && entry="$(dirname "$entry")";
    echo "${entry#/system/}";
  done;
}

case "$1" in
  backup)
    log " ";
    log "Backing up...";
    save_files | translate_path | while read -r object; do
      [ "$object" ] && [ -e "$S/$object" ] || continue;
      backup_file "$S/$object";
      log "BACKUPER: Object backed up ($object)";
    done;
  ;;
  restore)
    log " ";
    log "Restoring...";
    save_files | translate_path | while read -r object; do
      [ "$object" ] && [ -e "$C/$S/$object" ] || continue;
      restore_file "$S/$object";
      log "RESTORER: Object restored ($object)";
    done;
  ;;
  post-restore)
    log " ";
    log "Debloating...";
    delete_files | translate_path | while read -r object; do
      [ "$object" ] && [ -e "$S/$object" ] || continue;
      rm -rf "$S/$object";
      log "DEBLOATER: Object debloated ($object)";
    done;
  ;;
esac;
EOF

}

# Place an init script
initscript_install() {

  log " ";
  log "POST-INSTALL: Installing init script";

  if [ "$magisk" = "yes" ]; then
    init="/service.sh";
    touch "$root/$init";
    chmod 0777 "$root/$init";
  elif [ "$magisk" = "no" ]; then
    init="$init_file";
    mkdir -p "$(dirname "$root/$init")";
    touch "$root/$init";
    perm 0 0 0755 0777 "$(dirname "$root/$init")";
    chcon -hR 'u:object_r:system_file:s0' "$(dirname "$root/$init")";
  fi;

  cat << 'EOF' > "$root/$init";
#!/system/bin/sh
# MinMicroG bootup script

# Wait for bootup
while true; do [ "$(getprop sys.boot_completed)" = "1" ] && break; sleep 5; done;

# Fix GMS permission troubles
apk="/system/priv-app/MicroGGMSCore/MicroGGMSCore.apk";
[ -f "$apk" ] && pm install -r "$apk";

# Grant permissions
npem;
EOF

}
