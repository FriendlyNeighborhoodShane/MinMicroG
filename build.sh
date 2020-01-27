#!/bin/sh
# Build a package with $1 variant

workdir="$(pwd)";
cd "$workdir";
confvar="$1";
resdir="$workdir/res";
resdldir="$workdir/resdl";
tmpdir="$workdir/tmp";
reldir="$workdir/releases";
zipsigner="$(dirname "$workdir")/zipsigner.jar";
buildtime="$(date -u +%Y%m%d%H%M%S)";

echo " ";
echo "--       Minimal MicroG Build Script        --";
echo "--     The Essentials only MicroG pack      --";
echo "--      From the MicroG Telegram group      --";
echo "--         No, not the Official one         --";

for bin in cp grep java ls mv rm sed zip; do
  [ "$(which $bin)" ] || { echo " " >&2; echo "FATAL: No $bin found" >&2; return 1; }
done;
[ -f "$zipsigner" ] || { echo " " >&2; echo "FATAL: No zipsigner jar found" >&2; return 1; }

echo " ";
echo " - Working from $workdir";

echo " ";
echo " - Build started at $buildtime";

[ "$1" ] || { echo " " >&2; echo "FATAL: No variant specified to build" >&2; return 1; }

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

[ -f "$workdir/conf/defconf-$confvar.txt" ] || { echo " " >&2; echo "FATAL: No variant defconf found" >&2; return 1; }

echo " ";
echo " - Building package $confvar";

rm -Rf "$tmpdir";
mkdir -p "$tmpdir";

# Config

cp -Rf "$workdir/conf/defconf-$confvar.txt" "$tmpdir/defconf";
eval "$(cat "$tmpdir/defconf")" || { echo " " >&2; echo "FATAL: Config for $confvar cannot be executed" >&2; return 1; };
echo " ";
echo " - Config says variant $variant";

# Copy neccesary files

echo " ";
echo " - Copying files...";

for file in "$workdir/src/META-INF" "$workdir/LICENSE" "$workdir/README.md"; do
  [ -e "$file" ] || { echo "ERROR: $file doesn't exist" >&2; continue; }
  echo " -- BUILDER: Copying $file";
  cp -Rf "$file" "$tmpdir/";
done;

for object in $stuff $stuff_util; do
  for realobject in $resdir/"$object" $resdldir/"$object"; do
    [ -e "$realobject" ] || continue;
    echo " -- BUILDER: Copying $object";
    mkdir -p "$tmpdir/$(dirname "$object")/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/";
  done;
done;

for object in $stuff_arch $stuff_sdk $stuff_arch_sdk; do
  for realobject in $resdir/$(dirname "$object")/-*-/$(basename "$object") $resdldir/$(dirname "$object")/-*-/$(basename "$object"); do
    [ -e "$realobject" ] || continue;
    cond="$(basename "$(dirname "$realobject")")";
    echo " -- BUILDER: Copying $object ($cond)";
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

[ -f "$tmpdir/release.zip" ] || { echo " " >&2; echo "FATAL: Zip failed" >&2; return 1; }

# Sign

echo " ";
echo " - Signing zip...";

java -jar "$zipsigner" "$tmpdir/release.zip" "$tmpdir/release-signed.zip";

[ -f "$tmpdir/release-signed.zip" ] || { echo " " >&2; echo "FATAL: Zipsigner failed" >&2; return 1; }

# Done

echo " ";
echo " - Copying zip to releases...";

mkdir -p "$reldir";
mv -f "$tmpdir/release-signed.zip" "$reldir/MinMicroG-$variant-$ver-$buildtime-signed.zip";

[ -f "$reldir/MinMicroG-$variant-$ver-$buildtime-signed.zip" ] || { echo " " >&2; echo "FATAL: Move failed" >&2; return 1; }

# Done

echo " ";
echo " - Done!";

rm -Rf "$tmpdir";
echo " ";
