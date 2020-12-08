# MinMicroG

### By MOVZX and FatherJony and FriendlyNeighborhoodShane
*A simple, flexible MicroG/gang Installer*
**Licensed under the GNU GPL v3**

### Links
* [GitHub](https://github.com/FriendlyNeighborhoodShane/MinMicroG)
* [GitLab](https://gitlab.com/FriendlyNeighborhoodShane/MinMicroG)
* [Support in TeleGram group](https://t.me/microgsupport) (Ping me at @shanetheawesome)

### What is this?
This is a simple MicroG installer. It can install MicroG and other stuff into your system partition or as a Magisk module. It supports virtually all mobile architectures (arm/64, x86/64, mips/64) and fully supports KitKat and above. It can also (mostly) support much older versions, but sync adapters and some location providers won't work. It can even uninstall itself from your device, just rename it and flash it again.

The things included in the `Standard` Edition zip are:
 - MicroG (GMSCore, GSFProxy, Maps APIv1) (from MicroG FDroid repo)
 - Google Play store (modded for IAPs by Setialpha)
 - UNLP backends (Dejá vu, LocalWiFi, Mozilla, Nominatim) (From FDroid repo)
 - UNLP LocalGSM backend (From @ploink 's fork)
 - AuroraDroid (From Whyorean's GitLab)
 - AuroraServices (From Whyorean's GitLab)
 - Swype libs for AOSP keyboard (From OpenGApps GitHub repo)
 - Some Google DRM jars (From OpenGApps GitHub repo)
 - Google Sync adapters for KK to Q (From OpenGApps GitHub repo)
 - Permission files for all of this
 - An addon.d file to backup/restore everything on a rom flash

The things included in the `NoGoolag` Edition zip are:
 - MicroG (GMSCore, GSFProxy, Maps APIv1) (from MicroG FDroid repo)
 - FakeStore (from MicroG FDroid repo)
 - UNLP backends (Dejá vu, LocalWiFi, Mozilla, Nominatim) (From FDroid repo)
 - UNLP LocalGSM backend (From @ploink 's fork)
 - AuroraStore (From Whyorean's GitLab)
 - AuroraDroid (From Whyorean's GitLab)
 - AuroraServices (From Whyorean's GitLab)
 - Permission files for all of this
 - An addon.d file to backup/restore everything on a rom flash

The things included in the `UNLP` Edition zip are:
 - UNLP (From FDroid repo)
 - Maps APIv1
 - UNLP backends (Dejá vu, LocalWiFi, Mozilla, Nominatim) (From FDroid repo)
 - UNLP LocalGSM backend (From @ploink 's fork)
 - Permission files for all of this
 - An addon.d file to backup/restore everything on a rom flash

The things included in the `Minimal` Edition zip are:
 - MicroG (GMSCore, GSFProxy, Maps APIv1) (from MicroG FDroid repo)
 - FakeStore (from MicroG FDroid repo)
 - Permission files for all of this
 - An addon.d file to backup/restore everything on a rom flash

The things included in the `MinimalIAP` zip are:
 - MicroG (GMSCore, GSFProxy, Maps APIv1) (from MicroG FDroid repo)
 - Google Play store (modded for IAPs by Setialpha)
 - Some Google DRM jars (From OpenGApps GitHub repo)
 - Permission files for all of this
 - An addon.d file to backup/restore everything on a rom flash

The things included in the `AuroraServices` Edition zip are:
 - AuroraServices (From Whyorean's GitLab)
 - Permission files for all of this
 - An addon.d file to backup/restore everything on a rom flash

### Notes
Dirty flashing not recommended. you'll mess up all your permissions and may even cause conflicts in app data, leading to crashes.
The maker does not support or endorse dirty flashing. It will harm you and your loved ones. Don't come complaining to me.

How to control the zip by changing its name:
NOTE: Control by name is not possible in Magisk Manager, since it copies the zip to a cache directory and renames it install.zip. This is unavoidable behaviour.

 - Add `system` to its filename to force it to install/uninstall from system. Otherwise, it looks for Magisk, and if not found, installs to system. Obviously, if you flash it through Magisk Manager, you want to install it to Magisk. If not, you have to flash it through recovery.
   - Remember that choosing Magisk mode (which is the default if Magisk is installed already) will remove the MinMicroG package if you uninstall Magisk.

 - Add `uninstall` to its filename to uninstall it from your device, whether in Magisk mode or system mode. If you use Magisk Manager, your preffered method of uninstallation is from there.

Just rename it and flash it again for the intended effect. For example, `MinMicroG-variant-version-signed.zip` to `system-MinMicroG-variant-version-signed.zip` (and the same for uninstall).

NOTE: If you have made a system install but have Magisk installed as well, you will have to use both `system` and `uninstall` keywords in the name for an uninstall flash.

The zip debloats three specific Google apps from your phone (GmsCore, GoogleServicesFramework, Phonesky and their MicroG counterparts) and 4 NLP providers when the pack contents conflicts with them. In Magisk mode, they won't be removed from system, and if you uninstall the pack, they'll come back. If you install in system, the debloated stuff will be stored in internal-storage/MinMicroG/Backup.
WARNING: This zip does not and never will debloat anything else because that is the minimum coming in MicroG's way. I have had my own share of PTSD with debloating. I believe (through instinct) that it should work even on flashes over GApped ROMs, but don't take my word for it. Debloat before you flash.

For support with flashing:
If you flashed through recovery, provide its logs.
If you used Magisk Manager, provide its logs.

### How do I build these packs myself?
List of hard dependencies:
 - coreutils or equivalent [POSIX-compatible]
 - `curl` (update.sh)
 - `jq` (update.sh)
 - `unzip` (update.sh)
 - `zip` (build.sh)

cd to this directory and run:
```
> ./update.sh
```
To download all the assets to resdl directory.
```
> ./build.sh all
```
To build all the packs and place them in the releases directory.

That's it! If it tells you that some dependency is missing, install it.

You can pass `update.sh` several perl-style regexes as arguments to only download specific files.
You can pass `build.sh` some specific pack's conf names instead of all to build only the specific packs.

If you have the Java SDK and `openssl` installed, the update script will dump the signing certificates of all downloaded APKs and repo jars to resdl/util/certs. It will compare all future downloads with those certs, and in case of any signature errors or mismatches, will warn you.

If you have `aapt` installed, the update script will download the permission docs from the Android website, check the priv-apps for any new privileged permissions and tell you to add them to the whitelist in res/system/etc/permissions/[package].xml files.

To build your own custom pack, refer to custom-pack.md in the conf directory.

Any changes made to the code should ideally be tested with `test.sh`, which runs the shellcheck linter program on every script.

### Credits
 - Thanks to @osm0sis for the base magisk/recovery code and inspiration and guidance on the majority of the stuff in here.
 - Thanks to @Setialpha, the creator of NanoDroid, and ale5000 for the lib installation code, permissions code, and patched play.
 - Thanks to FDroid and the MicroG project for actively resisting monopoly and control so we can actually use our devices without fear.
 - Thanks to Whyorean for his amazing works in the form of the Aurora Apps.
 - Thanks to my friends over at NoGoolag for their help and patience over however long it took me to learn to do shit without "rm -rf /"-ing devices.

And most of all, thank you Google & gang for being so shitty to people and thus giving us a mission.
