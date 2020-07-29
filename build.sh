#!/bin/sh

# Build a package with $1 variant
#
# Copyright 2018-2020 FriendlyNeighborhoodShane
# Distributed under the terms of the GNU GPL v3

abort() {
  echo " " >&2;
  echo "!!! FATAL ERROR: $1" >&2;
  echo " " >&2;
  [ -d "$tmpdir" ] && rm -rf "$tmpdir";
  exit 1;
}

workdir="$(pwd)";
cd "$workdir" || abort "Can't cd to $workdir";
resdir="$workdir/res";
resdldir="$workdir/resdl";
reldir="$workdir/releases";
buildtime="$(date -u +%Y%m%d%H%M%S)";

echo " ";
echo "--       Minimal MicroG Build Script        --";
echo "--     The Essentials only MicroG pack      --";
echo "--      From the MicroG Telegram group      --";
echo "--         No, not the Official one         --";

for bin in cp grep ls mv rm sed zip; do
  [ "$(which $bin)" ] || abort "No $bin found";
done;

echo " ";
echo " - Working from $workdir";

echo " ";
echo " - Build started at $buildtime";

[ "$1" ] || abort "No variant specified to build";

if [ "$1" = "all" ]; then
  echo " ";
  echo " - Building all packages...";
  echo " ";
  for var in $(find "$workdir/conf" -name "defconf-*.txt" | sed -e "s|^$workdir/conf/defconf-||g" -e "s|.txt$||g"); do
    echo " - Executing build for $var...";
    "$workdir/build.sh" "$var";
  done;
  exit;
elif [ "$#" -gt "1" ]; then
  echo " ";
  echo " - Building packages: $*...";
  echo " ";
  for var in "$@"; do
    echo " - Executing build for $var...";
    "$workdir/build.sh" "$var";
  done;
  exit;
fi;

confvar="$1";
[ -f "$workdir/conf/defconf-$confvar.txt" ] || abort "No $confvar variant defconf found";

echo " ";
echo " - Building package $confvar";

tmpdir="$(mktemp -d)";
rm -rf "$tmpdir";
mkdir -p "$tmpdir";

# Config

cp -f "$workdir/conf/defconf-$confvar.txt" "$tmpdir/defconf";
chmod +x "$tmpdir/defconf";
. "$tmpdir/defconf" || abort "Config for $confvar cannot be executed";

echo " ";
echo " - Config says variant $variant";

# Copy neccesary files

echo " ";
echo " - Copying files...";

for file in "$workdir/src/META-INF" "$workdir/install.md" "$workdir/LICENSE" "$workdir/README.md"; do
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
  for realobject in "$resdir/$(dirname "$object")"/-*-/"$(basename "$object")" "$resdldir/$(dirname "$object")"/-*-/"$(basename "$object")"; do
    [ -e "$realobject" ] || continue;
    cond="$(basename "$(dirname "$realobject")")";
    echo " -- BUILDER: Copying $object ($cond)";
    mkdir -p "$tmpdir/$(dirname "$object")/$cond/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/$cond/";
  done;
done;

# Pre build actions

pre_build_actions;

# Zip

echo " ";
echo " - Zipping files...";

cd "$tmpdir" || abort "Can't cd to $tmpdir";
zip -r9q "$tmpdir/release.zip" "." || abort "Zip failed";
cd "$workdir" || abort "Can't cd to $workdir";

# Post build actions

post_build_actions;

# Copy zip

echo " ";
echo " - Copying zip to releases...";

mkdir -p "$reldir";
mv -f "$tmpdir/release.zip" "$reldir/MinMicroG-$variant-$ver-$buildtime.zip" || abort "Move failed";

# Done

echo " ";
echo " - Done!";

rm -rf "$tmpdir";
echo " ";
