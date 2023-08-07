#!/bin/sh

# Build a package with $1 variant
#
# Copyright 2018-2020 FriendlyNeighborhoodShane
# Distributed under the terms of the GNU GPL v3

abort() {
  echo " ";
  echo "!!! FATAL ERROR: $1";
  echo " ";
  [ -d "$tmpdir" ] && rm -rf "$tmpdir";
  exit 1;
}

workdir="$(pwd)";
confdir="$workdir/conf";
resdir="$workdir/res";
resdldir="$workdir/resdl";
reldir="$workdir/releases";
buildtime="$(date -u +%Y%m%d%H%M%S)";

echo " ";
echo "--       Minimal MicroG Build Script        --";
echo "--     The Essentials only MicroG pack      --";
modname="MinMicroG";

for bin in cp find grep mv rm sed zip; do
  command -v "$bin" >/dev/null || abort "No $bin found";
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
  varlist="$(find "$confdir" -type f -name "defconf-*.txt" -exec expr {} : ".*/defconf-\(.*\)\.txt$" ';')";
  for var in $varlist; do
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
[ -f "$confdir/defconf-$confvar.txt" ] || abort "No $confvar variant defconf found";

echo " ";
echo " - Building package $confvar";

tmpdir="$(mktemp -d)";
rm -rf "$tmpdir";
mkdir -p "$tmpdir";

# Config

cp -f "$confdir/defconf-$confvar.txt" "$tmpdir/defconf";
. "$tmpdir/defconf" || abort "Config for $confvar cannot be executed";

echo " ";
echo " - Config says variant $variant";

# Copy neccesary files

echo " ";
echo " - Copying files...";

for file in "src/META-INF" "src/customize.sh" "INSTALL.md" "LICENSE" "README.md"; do
  [ -e "$workdir/$file" ] || { echo "ERROR: $file doesn't exist"; continue; }
  echo " -- BUILDER: Copying $file";
  cp -Rf "$workdir/$file" "$tmpdir/";
done;

# KernelSU expects module.prop in zip
echo "$modprop" > "$tmpdir/module.prop"

for object in $stuff $stuff_util; do
  found="";
  for realobject in "$resdldir/$object" "$resdir/$object"; do
    [ -e "$realobject" ] && found="yes" || continue;
    echo " -- BUILDER: Copying $object";
    mkdir -p "$tmpdir/$(dirname "$object")/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/";
  done;
  [ "$found" ] || echo "ERROR: object not found ($object)";
done;

for object in $stuff_arch $stuff_sdk $stuff_arch_sdk; do
  found="";
  for realobject in "$resdldir/$(dirname "$object")"/-*-/"$(basename "$object")" "$resdir/$(dirname "$object")"/-*-/"$(basename "$object")"; do
    [ -e "$realobject" ] && found="yes" || continue;
    cond="$(basename "$(dirname "$realobject")")";
    echo " -- BUILDER: Copying $object ($cond)";
    mkdir -p "$tmpdir/$(dirname "$object")/$cond/";
    cp -Rf "$realobject" "$tmpdir/$(dirname "$object")/$cond/";
  done;
  [ "$found" ] || echo "ERROR: object not found ($object)";
done;

# Pre build actions

pre_build_actions;

# Zip

echo " ";
echo " - Zipping files...";

(
  cd "$tmpdir" && zip -r9q "$tmpdir/release.zip" ".";
) || abort "Zip failed";

# Post build actions

post_build_actions;

# Copy zip

echo " ";
echo " - Copying zip to releases...";

mkdir -p "$reldir";
mv -f "$tmpdir/release.zip" "$reldir/$modname-$variant-$ver-$buildtime.zip" || abort "Move failed";

# Done

echo " ";
echo " - Done!";

rm -rf "$tmpdir";
echo " ";
