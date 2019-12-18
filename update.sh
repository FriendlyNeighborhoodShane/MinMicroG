#!/bin/sh
# Update all assets

workdir="$(pwd)";
cd "$workdir";
confdir="$workdir/conf";
resdldir="$workdir/resdl";
tmpdir="$workdir/tmp";
updatetime="$(date -u +%Y%m%d%H%M%S)";
updatelog="$workdir/releases/update-$updatetime.log";

echo " ";
echo "--       Minimal MicroG Update Script       --";
echo "--      The Essentials Only MicroG Pack     --";
echo "--      From The MicroG Telegram group      --";
echo "--         No, not the Official one         --";

# Bin check
for bin in awk chmod cp curl grep head jq mv rm sort unzip wget; do
  [ "$(which $bin)" ] || { echo " "; echo "FATAL: No $bin found"; return 1; }
done;

echo " ";
echo " - Working from $workdir";

echo " ";
echo " - Update started at $updatetime";

echo " ";
echo " - Cleaning...";
  
rm -Rf "$tmpdir";
mkdir -p "$tmpdir" "$tmpdir/repos" "$(dirname "$updatelog")";

# Config

[ -f "$confdir/resdl-download.txt" ] || { echo " "; echo "F: No resdl-download.txt found"; return 1; }
eval "$(cat "$confdir/resdl-download.txt")" || { echo "FATAL: resdl-download.txt cannot be executed"; return 1; };

if [ $@ ]; then
  echo " ";
  echo " - Building update list...";
  stuff_download_new="";
  stuff_repo_new="";
  for include in $@; do
    echo " -- CONFIG: Including $include";
    stuff_download_new="$stuff_download_new
$(echo "$stuff_download" | grep -Pi "^[ \t]*[^ \t]*$include[^ \t]*[ \t]+")
";
  done;
  stuff_download="$(echo "$stuff_download_new" | sort -u)";
  repo_apps="$(echo "$stuff_download" | grep -P "^[ \t]*[^ \t]+[ \t]+repo[ \t]+")";
  for repo in $(echo "$repo_apps" | awk '{ print $3 }'); do
    stuff_repo_new="$stuff_repo_new
$(echo "$stuff_repo" | grep -P "^[ \t]*$(dirname "$repo")[ \t]+" | head -n1)
";
  done;
  stuff_repo="$(echo "$stuff_repo_new" | sort -u)";
fi; 

# Pre update actions

pre_update_actions;

# Download repos

echo " ";
echo " - Downloading repos...";

for repo in $(echo "$stuff_repo" | awk '{ print $1 }'); do
  line="$(echo "$stuff_repo" | grep -P "^[ \t]*$repo[ \t]+" | head -n1)";
  repourl="$(echo "$line" | awk '{ print $2 }')";
  [ "$repourl" ] || { echo "ERROR: Repo $repo has no URL"; continue; }
  echo " -- REPO: Downloading repo $repo";
  wget -q --show-progress "$repourl/index-v1.jar" -O "$tmpdir/repos/$repo.jar";
  [ -f "$tmpdir/repos/$repo.jar" ] || { echo "ERROR: Repo $repo failed to download"; continue; }
  unzip -oq "$tmpdir/repos/$repo.jar" "index-v1.json" -d "$tmpdir/repos/";
  [ -f "$tmpdir/repos/index-v1.json" ] || { echo "ERROR: Repo $repo failed to unzip"; continue; }
  mv -f "$tmpdir/repos/index-v1.json" "$tmpdir/repos/$repo.json";
  [ -f "$tmpdir/repos/$repo.json" ] || { echo "ERROR: Repo $repo failed to rename"; continue; }
done;

# Download assets

echo " ";
echo " - Downloading assets...";

for object in $(echo "$stuff_download" | awk '{ print $1 }'); do
  line="$(echo "$stuff_download" | grep -P "^[ \t]*$object[ \t]+" | head -n1)";
  source="$(echo "$line" | awk '{ print $2 }')";
  objectpath="$(echo "$line" | awk '{ print $3 }')";
  objectarg="$(echo "$line" | awk '{ print $4 }')";
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
          objecturl="$(curl -sN "https://api.github.com/repos/$objectpath/releases" | jq -r '.[].assets[].browser_download_url' | grep -P "$objectarg$" | head -n1)";
        ;;
        gitlab)
          echo " ---- Getting GitLab project ID for $object";
          objectid="$(curl -sN https://gitlab.com/$objectpath | grep "Project ID" | head -n1 | awk '{ print $3 }')";
          [ "$objectid" ] || { echo "ERROR: $object gitlab project ID not found"; continue; }
          echo " ---- Getting GitLab URL for $object";
          objectupload="$(curl -sN "https://gitlab.com/api/v4/projects/$objectid/repository/tags" | jq -r '.[].release.description' | grep -Po "(/uploads/[^()]*$objectarg)" | head -n1 | tr -d "()")";
          [ "$objectupload" ] || { echo "ERROR: $object gitlab project upload not found"; continue; }
          objecturl="https://gitlab.com/$objectpath$objectupload";
        ;;
        repo)
          objectrepo="$(dirname "$objectpath")";
          objectpackage="$(basename "$objectpath")";
          [ "$objectrepo" -a "$objectpackage" ] || { echo "ERROR: $object has no valid repo arguments"; continue; }
          [ -f "$tmpdir/repos/$objectrepo.json" ] || { echo "ERROR: $object repo $objectrepo does not exist"; continue; }
          echo " ---- Getting repo URL for $object from repo $repo";
          objectserver="$(jq -r '.repo.address' "$tmpdir/repos/$objectrepo.json")";
          if [ "$objectarg" ]; then
            echo " ---- Getting object for arch $objectarg";
            objectserverfile="$(jq -r --arg pkg "$objectpackage" --arg arch "$objectarg" '[.packages[$pkg][] | select (.nativecode[]==$arch).apkName][]' "$tmpdir/repos/$objectrepo.json" | head -n1)";
          else
            objectserverfile="$(jq -r --arg pkg "$objectpackage" '.packages[$pkg][].apkName' "$tmpdir/repos/$objectrepo.json" | head -n1)";
          fi;
          [ "$objectserver" -a "$objectserverfile" ] || { echo "ERROR: $object has no URL available"; continue; } 
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
      wget -q --show-progress "$objecturl" -O "$objectfile" || { echo "ERROR: $object failed to download"; continue; }
      [ -f "$objectfile" ] || { echo "ERROR: $object failed to download"; continue; }
      echo "NAME: $objectname, FILE: $object, URL: $objecturl;" >> "$updatelog";
    ;;
  esac;
  mkdir -p "$resdldir/$(dirname "$object")";
  mv -f "$objectfile" "$resdldir/$object";
  [ -f "$resdldir/$object" ] || { echo "ERROR: $object failed to copy"; continue; } 
done;

# Post update actions

post_update_actions;

# Done

echo " ";
echo " - Done!";

rm -Rf "$tmpdir";
echo " ";
