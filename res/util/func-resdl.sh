# Functions for use by resdl updater

# Extract maps jar from release zip
unzipmaps() {

  mapsfile="system/framework/com.google.android.maps";

  [ -f "$resdldir/$mapsfile.zip" ] || return 0;

  echo " ";
  echo " - Unzipping maps JAR...";

  rm -rf "$resdldir/$mapsfile.jar";
  unzip -oq -j "$resdldir/$mapsfile.zip" "$mapsfile.jar" -d "$resdldir/$(dirname "$mapsfile")/";
  rm -rf "$resdldir/$mapsfile.zip";

}

# Get update delta
updatedelta() {

  newlog=""
  oldlogs=""
  for log in $(ls -td "$reldir"/update-*.log); do
    [ "$(basename "$log")" = "update-$updatetime.log" ] && newlog="$(basename "$log")" || oldlogs="$oldlogs $(basename "$log")";
  done;
  [ "$newlog" ] && [ "$oldlogs" ] || return 0;

  echo " ";
  echo " - Checking resdl delta between updates...";

  for entry in $(grep -oE "FILE: [^,;]*" "$reldir/$newlog" | cut -d" " -f2); do
    line="$(grep "FILE: $entry," "$reldir/$newlog")";
    file="$entry";
    url="$(echo "$line" | grep -oE "URL: [^,;]*" | cut -d" " -f2)";
    oldurl="";
    for log in $oldlogs; do
      oldurl="$(grep "FILE: $file," "$reldir/$log" | grep -oE "URL: [^,;]*" | cut -d" " -f2)";
      [ "$oldurl" ] && break;
    done;
    [ "$oldurl" ] || oldurl="None";
    [ "$url" = "$oldurl" ] && continue;
    echo " -- Updated file: $file"
    echo "   ++ Old URL: $oldurl"
    echo "   ++ New URL: $url"
    echo "   ++ Old name: $(basename "$oldurl")"
    echo "   ++ New name: $(basename "$url")"
  done;

}

# Verify signatures of JARs and APKs
verifycerts() {

  [ "$stuff_repo" ] || echo "$stuff_download" | grep -qE "^[ ]*[^ ]+.apk[ ]+" || return 0;

  [ "$(which jarsigner)" ] && [ "$(which openssl)" ] || {
    echo " ";
    echo " !! Not checking certificates (missing jarsigner or openssl)";
    return 0;
  }

  certdir="$resdldir/util/certs";

  echo " ";
  echo " - Checking certs for repos...";

  for repo in $(echo "$stuff_repo" | select_word 1); do
    [ -f "$tmpdir/repos/$repo.jar" ] || continue;
    certobject="repo/$repo.cer";
    unzip -l "$tmpdir/repos/$repo.jar" "META-INF/*" | grep -q "META-INF/.*.RSA" && jarsigner -verify "$tmpdir/repos/$repo.jar" > /dev/null || {
      echo "  !! Verification failed for repo ($repo)";
      continue;
    }
    [ -f "$certdir/$certobject" ] || {
      echo "  -- Adding cert for new repo ($repo)";
      mkdir -p "$certdir/$(dirname "$certobject")";
      unzip -p "$tmpdir/repos/$repo.jar" "META-INF/*.RSA" | openssl pkcs7 -inform der -print_certs > "$certdir/$certobject";
      continue;
    }
    unzip -p "$tmpdir/repos/$repo.jar" "META-INF/*.RSA" | openssl pkcs7 -inform der -print_certs > "$tmpdir/tmp.cer";
    [ "$(diff -w "$tmpdir/tmp.cer" "$certdir/$certobject")" ] && {
      echo "  !! Cert mismatch for repo ($repo)";
      cp -f "$tmpdir/tmp.cer" "$certdir/$certobject.new";
    }
  done;

  echo " ";
  echo " - Checking certs for APKs...";

  for object in $(echo "$stuff_download" | grep -E "^[ ]*[^ ]+.apk[ ]+" | select_word 1); do
    [ -f "$resdldir/$object" ] || continue;
    certobject="$(dirname "$object")/$(basename "$object" .apk).cer";
    unzip -l "$resdldir/$object" "META-INF/*" | grep -q "META-INF/.*.RSA" && jarsigner -verify "$resdldir/$object" > /dev/null || {
      echo "  !! Verification failed for APK ($object)";
      continue;
    }
    [ -f "$certdir/$certobject" ] || {
      echo "  -- Adding cert for new APK ($object)";
      mkdir -p "$certdir/$(dirname "$certobject")";
      unzip -p "$resdldir/$object" "META-INF/*.RSA" | openssl pkcs7 -inform der -print_certs > "$certdir/$certobject";
      continue;
    }
    unzip -p "$resdldir/$object" "META-INF/*.RSA" | openssl pkcs7 -inform der -print_certs > "$tmpdir/tmp.cer";
    [ "$(diff -w "$tmpdir/tmp.cer" "$certdir/$certobject")" ] && {
      echo "  !! Cert mismatch for APK ($object)";
      cp -f "$tmpdir/tmp.cer" "$certdir/$certobject.new";
    }
  done;

}

# Check for needed priv-perm whitelists
checkwhitelist() {

  echo "$stuff_download" | grep -qE "^[ ]*/system/priv-app/[^ ]+.apk[ ]+" || return 0;

  [ "$(which aapt)" ] || {
    echo " ";
    echo " !! Not checking privperms (missing aapt)";
    return 0;
  }

  privpermlist="util/privperms.lst";
  privpermurl="https://developer.android.com/reference/android/Manifest.permission";

  echo " ";
  echo " - Getting priv-app permissions...";

  curl -L "$privpermurl" -o "$tmpdir/tmppage" || { echo "ERROR: Android permission docpage failed to download"; return 1; }

  lines="$(grep -nE "<!-- [=]* [A-Z ]* [=]* -->" "$tmpdir/tmppage" | grep -A1 "ENUM CONSTANTS DETAIL" | sed "s|:| |g" | select_word 1)";
  for line in $lines; do
    [ "$startline" ] && endline="$line" || startline="$line";
  done;
  cat "$tmpdir/tmppage" | head -n"$endline" | tail -n+"$startline" | tr -d "\n" | sed "s|<div data|\n|g" | grep -E -e "Protection level: [a-z|]*privileged" -e "Not for use by third-party applications" | grep -oE "android.permission.[A-Z_]*" > "$tmpdir/tmplist";
  echo "android.permission.FAKE_PACKAGE_SIGNATURE" >> "$tmpdir/tmplist";

  cat "$resdldir/$privpermlist" "$tmpdir/tmplist" 2>/dev/null | sort -u > "$tmpdir/sortedlist";
  mkdir -p "$resdldir/$(dirname "$privpermlist")"
  mv -f "$tmpdir/sortedlist" "$resdldir/$privpermlist";

  echo " ";
  echo " - Checking priv-app permissions...";

  for object in $(echo "$stuff_download" | grep -E "^[ ]*/system/priv-app/[^ ]+.apk[ ]+" | select_word 1); do
    [ -f "$resdldir/$object" ] || { echo "ERROR: Privapp $object not found"; continue; }
    privperms="";
    privapppackage="$(aapt dump badging "$resdldir/$object" | grep -oE "package: name=[^ ]*" | sed "s|'| |g" | select_word 3)"
    privappperms="$(aapt dump permissions "$resdldir/$object" | grep -oE "uses-permission: name=[^ ]*" | sed "s|'| |g" | select_word 3 | sort -u)";
    for privperm in in $privappperms; do
      grep -q "^$privperm$" "$resdldir/$privpermlist" || continue;
      grep -q "name=\"$privperm\"" "$resdir/system/etc/permissions/$privapppackage.xml" 2>/dev/null && continue;
      privperms="$privperm $privperms";
    done;
    [ "$privperms" ] || continue;
    echo " ";
    echo " -- File: $object";
    echo " -- Package: $privapppackage";
    for permentry in $privperms; do
      echo "   ++ Needs whitelisting perm $permentry";
    done;
  done;

}
