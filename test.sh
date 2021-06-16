#!/bin/sh

# Test the code with shellcheck
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

echo " ";
echo "--        Minimal MicroG Test Script        --";
echo "--     The Essentials only MicroG pack      --";

for bin in shellcheck; do
  [ "$(which $bin)" ] || abort "No $bin found";
done;

# These tests are only excluded in the command because they're pointless
# We don't need to do them and they only cloud the output

# SC1087: braces for array expansion
  # False positive from extended regex
  # Arrays aren't in sh anyway
# SC1090: non-constant source
# SC2034: assigned but not used
# SC2154: used but not assigned
  # All three happen all the time due to sourcing
  # Can't add directives because it's all dynamic

echo " ";
shellcheck -s sh -e 1087,1090,2034,2154 "$@" -- ./src/META-INF/com/google/android/update-binary ./build.sh ./test.sh ./update.sh ./conf/*.txt ./res/util/*.sh;
