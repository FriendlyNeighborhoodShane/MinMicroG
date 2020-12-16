#!/bin/sh

# Update all assets
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
updatetime="$(date -u +%Y%m%d%H%M%S)";
updatelog="$reldir/update-$updatetime.log";

select_word() {
  select_term="$1";
  cat | while read -r select_line; do
    select_current=0;
    select_found="";
    for select_each in $select_line; do
      select_current="$(( select_current + 1 ))";
      [ "$select_current" = "$select_term" ] && { select_found="yes"; break; }
    done;
    [ "$select_found" = "yes" ] && echo "$select_each";
  done;
}

echo " ";
echo "--       Minimal MicroG Update Script       --";
echo "--      The Essentials Only MicroG Pack     --";
echo "--      From The MicroG Telegram group      --";
echo "--         No, not the Official one         --";

# Bin check
for bin in chmod cp curl grep head jq mv rm sort tr unzip; do
  [ "$(which $bin)" ] || abort "No $bin found";
done;

echo " ";
echo " - Working from $workdir";

echo " ";
echo " - Update started at $updatetime";

echo " ";
echo " - Cleaning...";

tmpdir="$(mktemp -d)";
rm -rf "$tmpdir";
mkdir -p "$tmpdir" "$tmpdir/repos" "$(dirname "$updatelog")";

# Config

[ -f "$confdir/resdl-download.txt" ] || abort "No resdl-download.txt found";
. "$confdir/resdl-download.txt" || abort "Cannot execute resdl-download.txt";

# Filter list by arguments if given
if [ "$*" ]; then
  echo " ";
  echo " - Building update list...";
  stuff_download_new="";
  stuff_repo_new="";
  for include in "$@"; do
    echo " -- CONFIG: Including $include";
    stuff_download_new="$stuff_download_new
$(echo "$stuff_download" | grep -iE "^[ ]*[^ ]*$include[^ ]*[ ]+")
";
  done;
  stuff_download="$(echo "$stuff_download_new" | sort -u)";
  repo_apps="$(echo "$stuff_download" | grep -E "^[ ]*[^ ]+[ ]+repo[ ]+")";
  for repo in $(echo "$repo_apps" | select_word 3); do
    stuff_repo_new="$stuff_repo_new
$(echo "$stuff_repo" | grep -E "^[ ]*$(dirname "$repo")[ ]+" | head -n1)
";
  done;
  stuff_repo="$(echo "$stuff_repo_new" | sort -u)";
fi;

# Pre update actions

pre_update_actions;

# Download repos

echo " ";
echo " - Downloading repos...";

for repo in $(echo "$stuff_repo" | select_word 1); do
  line="$(echo "$stuff_repo" | grep -E "^[ ]*$repo[ ]+" | head -n1)";
  repourl="$(echo "$line" | select_word 2)";
  [ "$repourl" ] || { echo "ERROR: Repo $repo has no URL"; continue; }
  echo " -- REPO: Downloading repo $repo";
  curl -L "$repourl/index-v1.jar" -o "$tmpdir/repos/$repo.jar" || { echo "ERROR: Repo $repo failed to download"; continue; }
  unzip -oq "$tmpdir/repos/$repo.jar" "index-v1.json" -d "$tmpdir/repos/" || { echo "ERROR: Repo $repo failed to unzip"; continue; }
  mv -f "$tmpdir/repos/index-v1.json" "$tmpdir/repos/$repo.json" || { echo "ERROR: Repo $repo failed to rename"; continue; }
done;

# Download assets

echo " ";
echo " - Downloading assets...";

for object in $(echo "$stuff_download" | select_word 1); do
  line="$(echo "$stuff_download" | grep -E "^[ ]*$object[ ]+" | head -n1)";
  source="$(echo "$line" | select_word 2)";
  objectpath="$(echo "$line" | select_word 3)";
  objectarg="$(echo "$line" | select_word 4)";
  [ "$objectpath" ] || { echo "ERROR: $object has no source arguments"; continue; }
  echo " -- ASSET: Downloading object $object from source $source";
  case "$source" in
    local)
      objectfile="$objectpath";
    ;;
    *)
      case "$source" in
        direct)
          objecturl="$objectpath";
        ;;
        github)
          echo " ---- Getting GitHub URL for $object";
          objecturl="$(curl -Ls "https://api.github.com/repos/$objectpath/releases" | jq -r '.[].assets[].browser_download_url' | grep "$objectarg$" | head -n1)";
        ;;
        gitlab)
          echo " ---- Getting GitLab project ID for $object";
          objectid="$(curl -Ls "https://gitlab.com/$objectpath" | grep "Project ID" | head -n1 | select_word 3)";
          [ "$objectid" ] || { echo "ERROR: $object gitlab project ID not found"; continue; }
          echo " ---- Getting GitLab URL for $object";
          objectupload="$(curl -Ls "https://gitlab.com/api/v4/projects/$objectid/repository/tags" | jq -r '.[].release.description' | grep -oE "(/uploads/[^()]*$objectarg)" | head -n1 | tr -d "()")";
          [ "$objectupload" ] || { echo "ERROR: $object gitlab project upload not found"; continue; }
          objecturl="https://gitlab.com/$objectpath$objectupload";
        ;;
        repo)
          objectrepo="$(dirname "$objectpath")";
          objectpackage="$(basename "$objectpath")";
          [ "$objectarg" ] && {
            objectarch="$(echo "$objectarg" | sed "s|:| |g" | select_word 1)";
            objectsdk="$(echo "$objectarg" | sed "s|:| |g" | select_word 2)";
          }
          [ "$objectrepo" ] && [ "$objectpackage" ] || { echo "ERROR: $object has no valid repo arguments"; continue; }
          [ -f "$tmpdir/repos/$objectrepo.json" ] || { echo "ERROR: $object repo $objectrepo does not exist"; continue; }
          echo " ---- Getting repo URL for $object from repo $objectrepo";
          objectserver="$(jq -r '.repo.address' "$tmpdir/repos/$objectrepo.json")";
          if [ "$objectarg" ]; then
            echo " ---- Getting object for args $objectarg [$objectarch] [$objectsdk]";
            objectserverfile="$(jq -r --arg pkg "$objectpackage" --arg arch "$objectarch" --arg sdk "$objectsdk" '.packages[$pkg][] | if ( $arch | length ) == 0 then . elif has ( "nativecode" ) then select ( .nativecode[]? == $arch ) else . end | if ( $sdk | length ) == 0 then . else select ( ( .minSdkVersion | tonumber ) <= ( $sdk | tonumber ) ) end | .apkName' "$tmpdir/repos/$objectrepo.json" | head -n1)";
          else
            objectserverfile="$(jq -r --arg pkg "$objectpackage" '.packages[$pkg][].apkName' "$tmpdir/repos/$objectrepo.json" | head -n1)";
          fi;
          [ "$objectserver" ] && [ "$objectserver" != "null" ] && [ "$objectserverfile" ] && [ "$objectserverfile" != "null" ] || { echo "ERROR: $object has no URL available"; continue; }
          objecturl="$objectserver/$objectserverfile";
        ;;
        *)
          echo "ERROR: Source $source for $object unknown";
        ;;
      esac;
      [ "$objecturl" ] || { echo "ERROR: $object has no URL available"; continue; }
      objectname="$(basename "$objecturl")";
      objectfile="$tmpdir/$objectname";
      echo " ---- Downloading $objecturl";
      curl -L "$objecturl" -o "$objectfile" || { echo "ERROR: $object failed to download"; continue; }
      echo "NAME: $objectname, FILE: $object, URL: $objecturl;" >> "$updatelog";
    ;;
  esac;
  mkdir -p "$resdldir/$(dirname "$object")";
  mv -f "$objectfile" "$resdldir/$object" || { echo "ERROR: $object failed to copy"; continue; }
done;

# Post update actions

post_update_actions;

# Done

echo " ";
echo " - Done!";

rm -rf "$tmpdir";
echo " ";
