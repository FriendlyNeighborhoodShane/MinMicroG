# conf

All the config files for packs.

Every pack is built and installed according to a config file. A config file is supposed to be a simple shell script setting some variables and functions. It's not supposed to execute any command, which is important, as it is executed by both the building process on the building device and the flashing process on the flashing device.

All the config files are named as defconf-[name].txt where [name] is the argument you'll pass to `build.sh` to build a pack using that config file.
The resdl-download.txt file is a special config that is read by `update.sh` to download all the relevant dynamic assets.
The rest of the files here are code snippets you might find useful to put in install actions.

For making your own pack and config file, check custom-pack.md

## Variables in defconf files

 - `variant`: The name that will be in the filename of the released zip as well as will be shown on installation. It does not have to be related to the name of the defconf file (for example the defconf-unlp.txt file has variant "Backend" and creates the MinMicroG-Backend-*-*.zip package). Any string without whitespace will do.
 - `ver`: The version number of the package, which is shown in the release filename and during installation. It can be anything except whitespace, but for convenience is integers along with decimals.
 - `verc`: The version code for the package. It's only really used in Magisk installations's mod.prop, where Magisk compares it to decide if a version of the module is newer than the installed version. It strictly has to be an integer.
 - `date`: The date of releasing the specific pack version, shown on installation.
 - `minsdk`: The minimum Android SDK version the pack supports fully. It'll still install below that, but will show a warning to the user.
 - `modprop`: The variable containing the entirety of Magisk's mod.prop, which will appear in your installed modules. Nothing really important here except verc, which is described above, and id, which has to be the same as modname variable from update-binary.
 - `stuff`, `stuff_arch`, `stuff_sdk`, `stuff_arch_sdk`: Stuff variables are really space/tab-separated lists of all the objects (Relative to the root of the zip during flashing, or relative to either res or resdl directories in the build process) that are installed to be installed to device. It is going to be put through a for loop, so no whitespace is to be used in a single entry. Luckily, android system files aren't supposed to have spaces in their names/paths. For files in `stuff`, the file with that path is grabbed directly from res or resdl (in ascending priority), while for the other arrays, the files are grabbed from $(dirname [path])/-*-/$(basename [path]) (further clarification in build-your-pack.md).
 - `stuff_util`: Same whitespace-separated list as above, but for things that should be grabbed from res or resdl during building, but not placed during installation. Could be used for extra tools used in the hook funcs.
 - `stuff_other`, `stuff_old`: Just lists of stuff from other packs and stuff that used to be in any of the packs that I made for organisation. They have no purpose other than to be merged in stuff_uninstall.
 - `stuff_uninstall`: Everything in this list is removed from system during a system installation and uninstallation. Should include everything in the pack, along with anything that used to be in it and anything that might be from alternative conflicting packs.
 - `stuff_debloat`: Anything not from these packs that might conflict with it. For example GApps, other location providers, etc. They are removed (and backed up) during a system install and pseudo-debloated during a Magisk install.
 - `stuff_perm`: Subdirectories of /system on which permission are to be applied in case of a system installation. This variable exists because perming the whole system takes too long.

## Functions in defconf files

 - `pre_build_actions()`
 - `post_build_actions()`
 - `pre_install_actions()`
 - `post_install_actions()`
 - `pre_uninstall_actions()`
 - `post_uninstall_actions()`

Pretty self explanatory. Leave them blank with a return 0 if there's no use for them, not having them at all will cause errors.

## Variables in resdl-conf file

 - `stuff_repos`: List of FDroid format app repositories that are to be downloaded and their contents used by update.sh. First column has their names, which are to be unique and are the key to access them in stuff_download. Second column is the URL, to which appending '/index-v1.jar' should result in an object downloadable by wget.
 - `stuff_download`: List of actual objects that are put into resdl by `update.sh`. First column is the filepath inside resdl that it should be put in. Second column is the source that it comes from, which is one of local, direct, github, gitlab, or repo. Other columns depend upon the source and any extra columns are ignored. For local, third column is a path resolved against the repo directory from which the file is cp'd to the destination. For direct, the third column is a URL that must be downloadable using wget. For github and gitlab, the third column is [repo owner]/[repo name] from which the newest file is grabbed from the releases page, optionally filtering only for the regex-enabled suffix in the fourth column if provided. For repo, it's the [repo key]/[package name] of which the latest APK is grabbed, optionally filtering for the arch and minimum SDK if provided in the third column in the format ARCH:SDK (one of these variables can be ommitted but not the colon).

## Functions in resdl-conf file

 - `pre_update_actions()`
 - `post_update_actions()`

Again, they speak for themselves.
