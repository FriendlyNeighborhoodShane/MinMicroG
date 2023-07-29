#!/bin/sh

# Bump versions in defconf files
#
# Copyright 2018-2020 FriendlyNeighborhoodShane
# Distributed under the terms of the GNU GPL v3

abort() {
  echo " ";
  echo "!!! FATAL ERROR: $1";
  echo " ";
  exit 1;
}

workdir="$(pwd)";
confdir="$workdir/conf";

quote_str() {
  printf '"%s"' "$1";
}

echo " ";
echo "--        Minimal MicroG Test Script        --";
echo "--     The Essentials only MicroG pack      --";

for bin in printf sed; do
  command -v "$bin" >/dev/null || abort "No $bin found";
done;

[ "$#" = "3" ] || abort "Insufficient arguments: [version] [version number] [date]";

echo " ";
echo " - Bumping defconfs: [$1] [$2] [$3]";

for i in "ver=$(quote_str "$1")" "verc=$(quote_str "$2")" "date=$(quote_str "$3")"; do
  sed -i "s|${i%%=*}=.*|$i;|g" -- "$confdir"/defconf-*.txt;
done;

echo " ";
echo " - Done!";
echo " ";
