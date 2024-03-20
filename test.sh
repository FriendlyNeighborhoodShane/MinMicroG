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

# SC1087: braces for array expansion
  # False positive from extended regex
  # Arrays aren't in sh anyway
# SC1090: non-constant source
# SC1091: not specified as input
# SC2034: assigned but not used
# SC2154: used but not assigned
  # All three happen all the time due to sourcing
  # Can't add directives because it's all dynamic

for script in src/META-INF/com/google/android/update-binary build.sh bump.sh test.sh update.sh res/util/script-addon.sh res/util/script-init.sh; do
  echo " ";
  echo " - Linting script: $script";
  shellcheck -s sh -ax -W 0 -e 1087,1090,1091,2034,2154 "$@" -- "$workdir/$script";
done;

echo " ";
echo " - Done!";
echo " ";
