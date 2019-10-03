#!/bin/sh
# Build a package with $1 variant

workdir="$(dirname "$0")";
confvar="$1";
resdir="$workdir/res";
resdldir="$workdir/resdl";
tmpdir="$workdir/tmp";
rel="$workdir/releases";

[ "$1" ] || { echo " "; echo "FATAL: No variant specified to build"; exit 1; }

[ -f "$workdir/confs/defconf-$confvar.txt" ] || { echo " "; echo "FATAL: No variant defconf found"; exit 1; }

rm -rf "$tmpdir";
mkdir -p "$tmpdir";

# Config

cp "$workdir/confs/defconf-$confvar.txt" "$tmpdir/defconf";
eval "$(cat "$tmpdir/defconf")";
[ "$confvar" == "$variant" ] || { echo " "; echo "FATAL: Variant from defconf don't match"; exit 1; }

# Copy neccesary files

for file in "$workdir/src/META-INF" "$workdir/LICENSE" "$workdir/README.md"; do
  [ -e "$file" ] || { echo "ERROR: $file doesn't exist"; continue; }
  cp -Rf "$file" "$tmpdir/";
done;

for object in $stuff; do
  for realobject in $resdir/"$object" $resdldir/"$object"; do
    [ -e "$realobject" ] || { echo "ERROR: $object doesn't exist"; continue; }
    mkdir -p "$tmpdir/$(dirname "$object")/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/";
  done;
done;

for object in $stuff_arch; do
  for realobject in $resdir/$(dirname "$object")/*-$arch-*/$(basename "$object") $resdldir/$(dirname "$object")/*-$arch-*/$(basename "$object"); do
    [ -e "$realobject" ] || { echo "ERROR: $object doesn't exist"; continue; }
    cond="$(basename "$(dirname "$realobject")")";
    mkdir -p "$tmpdir/$(dirname "$object")/$cond/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/$cond/";
  done;
done;

for object in $stuff_sdk; do
  for realobject in $resdir/$(dirname "$object")/*-$sdk-*/$(basename "$object") $resdldir/$(dirname "$object")/*-$sdk-*/$(basename "$object"); do
    [ -e "$realobject" ] || { echo "ERROR: $object doesn't exist"; continue; }
    cond="$(basename "$(dirname "$realobject")")";
    mkdir -p "$tmpdir/$(dirname "$object")/$cond/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/$cond/";
  done;
done;

for object in $stuff_arch_sdk; do
  for realobject in $resdir/$(dirname "$object")/*-$arch-*-$sdk-*/$(basename "$object") $resdldir/$(dirname "$object")/*-$arch-*-$sdk-*/$(basename "$object"); do
    [ -e "$realobject" ] || { echo "ERROR: $object doesn't exist"; continue; }
    cond="$(basename "$(dirname "$realobject")")";
    mkdir -p "$tmpdir/$(dirname "$object")/$cond/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/$cond/";
  done;
done;

# Zip

cd "$tmpdir";
zip -vr9 "$tmpdir/release.zip" *;

# Sign


mv -f "$tmpdir/release.zip" "$reldir/MinMicroG-$variant-$ver-signed.zip";
rm -rf "$tmpdir";
