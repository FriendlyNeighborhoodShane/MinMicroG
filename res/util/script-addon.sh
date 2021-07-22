#!/sbin/sh
#
# MinMicroG addon.d
#
# ADDOND_VERSION=2

save_files() {
cat <<EOL
@INSTALLLIST@

EOL
}

delete_files() {
cat <<EOL
@DEBLOATLIST@

EOL
}

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
      for file in $(find "$S/$object" -type f); do
        file="${file#$S/}";
        backup_file "$S/$file";
        log "BACKUPER: Object backed up ($file)";
      done;
    done;
  ;;
  restore)
    log " ";
    log "Restoring...";
    save_files | translate_path | while read -r object; do
      [ "$object" ] && [ -e "$C/$S/$object" ] || continue;
      for file in $(find "$C/$S/$object" -type f); do
        file="${file#$C/$S/}";
        restore_file "$S/$file";
        log "RESTORER: Object restored ($file)";
      done;
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
