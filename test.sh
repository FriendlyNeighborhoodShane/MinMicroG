#!/bin/sh

# Test the code with shellcheck
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

echo " ";
echo "--        Minimal MicroG Test Script        --";
echo "--     The Essentials only MicroG pack      --";

for bin in shellcheck; do
  command -v "$bin" >/dev/null || abort "No $bin found";
done;

# These tests are only excluded in the command because they're pointless
# We don't need to do them and they only cloud the output

# SC2034: assigned but not used

for script in src/META-INF/com/google/android/update-binary build.sh bump.sh test.sh update.sh res/util/script-addon.sh res/util/script-init.sh; do
  echo " ";
  echo " - Linting script: $script";
  shellcheck -s sh -ax -W 0 -e 2034 "$@" -- "$workdir/$script";
done;

echo " ";
echo " - Done!";
echo " ";
