#!/bin/sh
# Build a package with $1 variant

workdir="$(pwd)";
cd "$workdir":
confvar="$1";
resdir="$workdir/res";
resdldir="$workdir/resdl";
tmpdir="$workdir/tmp";
reldir="$workdir/releases";
zipsigner="$(dirname "$workdir")/zipsigner.jar";

echo " ";
echo "--       Minimal MicroG Build Script        --";
echo "--     The Essentials only MicroG pack      --";
echo "--      From the MicroG Telegram group      --";
echo "--         No, not the Official one         --";

echo " ";
echo " - Working from $workdir";

[ "$1" ] || { echo " "; echo "FATAL: No variant specified to build"; return 1; }

case "$1" in
  all)
    echo " ";
    echo " - Building all packages...";
    echo " ";
    for list in $(ls -1 "$workdir/conf" | grep -o "defconf-.*.txt" | sed -e "s|^defconf-||g" -e "s|.txt$||g"); do
      echo " - Executing build for $list...";
      "$workdir/build.sh" "$list";
    done;
    return;
  ;;
esac;

[ -f "$workdir/conf/defconf-$confvar.txt" ] || { echo " "; echo "FATAL: No variant defconf found"; return 1; }

echo " ";
echo " - Building package $confvar";

rm -Rf "$tmpdir";
mkdir -p "$tmpdir";

# Config

cp -Rf "$workdir/conf/defconf-$confvar.txt" "$tmpdir/defconf";
eval "$(cat "$tmpdir/defconf")";
echo " ";
echo " - Config says variant $variant";

# Copy neccesary files

echo " ";
echo " - Copying files...";

for file in "$workdir/src/META-INF" "$workdir/LICENSE" "$workdir/README.md"; do
  [ -e "$file" ] || { echo "ERROR: $file doesn't exist"; continue; }
  echo " -- BUILDER: Copying $file (to $tmpdir/)";
  cp -Rf "$file" "$tmpdir/";
done;

for object in $stuff; do
  for realobject in $resdir/"$object" $resdldir/"$object"; do
    [ -e "$realobject" ] || continue;
    echo " -- BUILDER: Copying $object ($realobject to $tmpdir/$(dirname "$object")/)";
    mkdir -p "$tmpdir/$(dirname "$object")/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/";
  done;
done;

for object in $stuff_arch $stuff_sdk $stuff_arch_sdk; do
  for realobject in $resdir/$(dirname "$object")/-*-/$(basename "$object") $resdldir/$(dirname "$object")/-*-/$(basename "$object"); do
    [ -e "$realobject" ] || continue;
    cond="$(basename "$(dirname "$realobject")")";
    echo " -- BUILDER: Copying $object ($realobject to $tmpdir/$(dirname "$object")/$cond/)";
    mkdir -p "$tmpdir/$(dirname "$object")/$cond/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/$cond/";
  done;
done;

# Zip

echo " ";
echo " - Zipping files...";

cd "$tmpdir";
zip -r9q "$tmpdir/release.zip" *;
cd "$workdir";

# Sign

echo " ";
echo " - Signing zip...";

java -jar "$zipsigner" "$tmpdir/release.zip" "$tmpdir/release-signed.zip";

# Done

echo " ";
echo " - Copying zip to releases...";

mkdir -p "$reldir";
mv -f "$tmpdir/release-signed.zip" "$reldir/MinMicroG-$variant-$ver-$(date +%Y%m%d%H%M%S)-signed.zip";

# Done

echo " ";
echo " - Done!";

rm -Rf "$tmpdir";
echo " ";
