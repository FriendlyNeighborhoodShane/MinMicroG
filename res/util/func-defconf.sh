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
    stuff="$(echo "$stuff" | sed 's| |\n|g' | sort -u | sed 's|^|  |g')
";
    stuff_arch="$(echo "$stuff_arch" | sed 's| |\n|g' | sort -u | sed 's|^|  |g')
";
    stuff_sdk="$(echo "$stuff_sdk" | sed 's| |\n|g' | sort -u | sed 's|^|  |g')
";
    stuff_arch_sdk="$(echo "$stuff_arch_sdk" | sed 's| |\n|g' | sort -u | sed 's|^|  |g')
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
  [ "$addond_file" ] && [ -e "$filedir/util/script-addon.sh" ] || return 1;

  log " ";
  log "POST-INSTALL: Installing addon.d script";

  addond="$addond_file";
  mkdir -p "$(dirname "$root/$addond")";
  touch "$root/$addond";
  perm 0 0 0755 0644 "$(dirname "$root/$addond")";
  chcon -hR 'u:object_r:system_file:s0' "$(dirname "$root/$addond")";

  cat "$filedir/util/script-addon.sh" > "$root/$addond";
  echo "$stuff" "$stuff_arch" "$stuff_sdk" "$stuff_arch_sdk" "$addond_file" "$init_file" | sed 's| |\n|g' | sort -u > "$filedir/util/INSTALLLIST";
  echo "$stuff_debloat" | sed 's| |\n|g' | sort -u > "$filedir/util/DEBLOATLIST";
  sed -i -e "/@INSTALLLIST@/r $filedir/util/INSTALLLIST" -e "/@INSTALLLIST@/d" "$root/$addond";
  sed -i -e "/@DEBLOATLIST@/r $filedir/util/DEBLOATLIST" -e "/@DEBLOATLIST@/d" "$root/$addond";

}

# Place an init script
initscript_install() {

  [ "$init_file" ] && [ -e "$filedir/util/script-init.sh" ] || return 1;

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

  cat "$filedir/util/script-init.sh" > "$root/$init";

}
