# MinMicroG

### By MOVZX and FatherJony and FriendlyNeighborhoodShane
*A simple, flexible MicroG/gang Installer*
**Licensed under the GNU GPL v3**

### Repositories
* [GitHub](https://github.com/FriendlyNeighborhoodShane/MinMicroG)
* [GitLab](https://gitlab.com/FriendlyNeighborhoodShane/MinMicroG)

### microG communities
* [/r/microG](https://reddit.com/r/microG) on Reddit
* [microG user group](https://t.me/microg) on Telegram

### What is this?
This is a simple MicroG installer. It can install MicroG and other stuff into
your system partition or as a Magisk module. It supports virtually all mobile
architectures (arm/64, x86/64, mips/64) and fully supports KitKat and above. It
can also (mostly) support much older versions, but sync adapters and some
location providers won't work. It can even uninstall itself from your device,
just rename it and flash it again.

### Variants
The `MinMicroG` packages are intended as various base configuration for microG,
they are all mutually exclusive with each other and you can only choose one.
While the `MinAddon` packages act as independent additions on top, you can have
as many as you wish over a base package, or even without a base package.

All of these include required permissions and an addon.d file to backup/restore
everything on a ROM flash in a system installation.

#### Table of contents of different MinMicroG variants
| Component \ Variant   | Standard | NoGoolag | Minimal | MinimalIAP |
|-----------------------|----------|----------|---------|------------|
| MicroG                | x        | x        | x       | x          |
| Maps APIv1            | x        | x        | x       | x          |
| Fake Store            |          | x        | x       |            |
| Google Play Store     | x        |          |         | x          |
| Aurora Store          |          | x        |         |            |
| Aurora Droid          | x        | x        |         |            |
| Aurora Services       | x        | x        |         |            |
| Swype libs            | x        |          |         |            |
| Google DRM jars       | x        |          |         | x          |
| Google Sync adapters  | x        |          |         |            |

#### List of MinAddon variants
They just consist of singular components, just what they say on their label.
- AuroraServices
- PlayStore

#### Package sources and credit
- MicroG includes GMSCore and GSFProxy from MicroG FDroid repo
- Maps APIv1 from MicroG FDroid repo
- Google Play Store modded from the Pixel Experience Gitlab
- Fake Store from MicroG FDroid repo
- Aurora Store, Aurora Droid and Aurora Services from Whyorean's GitLab
- Swype libs for AOSP keyboard from OpenGApps GitHub repo
- Some Google DRM jars from OpenGApps GitHub repo
- Google Sync adapters for KK-R from OpenGApps GitLab repo, and for S-T from MindTheGApps GitLab repo

### Uninstallation and notes
Dirty flashing not recommended. you'll mess up all your permissions and may
even cause conflicts in app data, leading to crashes.
The maker does not support or endorse dirty flashing. It will harm you and your
loved ones. Don't come complaining to me.

You can flash this zip either from your recovery (recommended) or through
Magisk Manager.

How to control the zip by changing its name:
NOTE: Control by name is not possible in Magisk Manager, since it copies the
zip to a cache directory and renames it install.zip. This is unavoidable
behaviour.

 - Add `system` to its filename to force it to install/uninstall from system.
   Otherwise, it looks for Magisk, and if not found, installs to system.
   Obviously, if you flash it through Magisk Manager, you want to install it to
   Magisk. If not, you have to flash it through recovery.
   - Remember that choosing Magisk mode (which is the default if Magisk is
     installed already) will remove the MinMicroG package if you uninstall
     Magisk.

 - Add `uninstall` to its filename to uninstall it from your device, whether in
   Magisk mode or system mode. If you use Magisk Manager, your preffered method
   of uninstallation is from there.

Just rename it and flash it again for the intended effect. For example,
`MinMicroG-variant-version-signed.zip` to
`system-MinMicroG-variant-version-signed.zip` (and the same for uninstall).

NOTE: If you have made a system install but have Magisk installed as well, you
will have to use both `system` and `uninstall` keywords in the name for an
uninstall flash.

The zip debloats three specific Google apps from your phone (GmsCore,
GoogleServicesFramework, Phonesky and their MicroG counterparts) and 4 NLP
providers when the pack contents conflicts with them. In Magisk mode, they
won't be removed from system, and if you uninstall the pack, they'll come back.
If you install in system, the debloated stuff will be stored in
`internal-storage/MinMicroG/Backup`.
WARNING: This zip does not and never will debloat anything else because that is
the minimum coming in MicroG's way. I have had my own share of PTSD with
debloating. I believe (through instinct) that it should work even on flashes
over GApped ROMs, but don't take my word for it. Debloat before you flash.

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

`cd` to this directory and run:
```
> ./update.sh
```
To download all the assets to `resdl` directory.
```
> ./build.sh all
```
To build all the packs and place them in the `releases` directory.

That's it! If it tells you that some dependency is missing, install it.

You can pass `update.sh` several extended regexes as arguments to only download
specific files.
You can pass `build.sh` some specific pack's conf names instead of all to build
only the specific packs.

If you have `apksigner` installed, the update script will dump the signing
certificates of all downloaded APKs and repo jars to `resdl/util/certs`. It
will compare all future downloads with those certs, and in case of any
signature errors or mismatches, will warn you.

If you have `aapt` installed, the update script will download the permission
docs from the Android website, check the priv-apps for any new privileged
permissions and tell you to add them to the whitelist in
`res/system/etc/permissions/[package].xml` files.

To build your own custom pack, refer to `conf/custom-conf.md`.

Any changes made to the code should ideally be tested with `test.sh`, which
runs the `shellcheck` linter program on every script.

Use `bump.sh` to automatically bump the `ver`, `verc` and `date` values across
all defconf files.

### Credits
 - Thanks to @osm0sis for the base magisk/recovery code and inspiration and
   guidance on the majority of the stuff in here.
 - Thanks to @Setialpha, the creator of NanoDroid, and ale5000 for the lib
   installation code, permissions code, and patched play.
 - Thanks to FDroid and the MicroG project for actively resisting monopoly and
   control so we can actually use our devices without fear.
 - Thanks to Whyorean for his amazing works in the form of the Aurora Apps.
 - Thanks to my friends over at NoGoolag for their help and patience over
   however long it took me to learn to do shit without "rm -rf /"-ing devices.

And most of all, thank you Google & gang for being so shitty to people and thus
giving us a mission.
