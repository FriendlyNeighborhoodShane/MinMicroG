# Minimal MicroG Installer
### By MOVZX and FatherJony and FriendlyNeighborhoodShane
*A simple, flexible MicroG Installer*

### Links
* [GitHub](https://github.com/FriendlyNeighborhoodShane/MicroG_Packs)
* [Support](https://t.me/joinchat/FyFlS0X2D7f6YNvdxhEsfw)
### Description
This is a simple MicroG installer. It can install MicroG into your system partition or as a Magisk module. It supports virtually all mobile architectures (arm/64, x86/64, mips/64) and fully supports KitKat and above. It can also (mostly) support much older versions, but sync adapters and some location providers won't work. It can even uninstall itself from your device, just rename it and flash it again.

It contains an unofficial fork of MicroG (GMSCore, GSFProxy, Droidguard) (Compiled by MOVZX) with bumped version numbers so that apps don't complain about updating playstore.

The things included in the Standard Edition zip are:
- MicroG (GMSCore, GSFProxy, Droidguard, Maps APIv1)
- Google Play store (modded for IAPs by Setialpha)
- UNLP backends (Dejá vu, LocalGSM, LocalWiFi, Mozilla, Nominatim)
- AuroraDroid
- AuroraServices
- Swype libs for AOSP keyboard
- Some Google DRM jars
- Google Sync adapters for KK to O
- Permission files for all of this
- An addon.d file to backup/restore everything on a rom flash

The things included in the NoGoolag Edition zip are:
- MicroG (GMSCore, GSFProxy, Droidguard, Maps APIv1)
- FakeStore
- AuroraStore
- AuroraDroid
- AuroraServices
- UNLP backends (Dejá vu, LocalGSM, LocalWiFi, Mozilla, Nominatim)
- Permission files for all of this
- An addon.d file to backup/restore everything on a rom flash

The things included in the UNLP Edition zip are:
- UNLP
- UNLP backends (Dejá vu, LocalGSM, LocalWiFi, Mozilla, Nominatim)
- Permission files for all of this
- An addon.d file to backup/restore everything on a rom flash

The zip debloats 3 Google apps from your phone (GmsCore, GoogleServicesFramework, Phonesky and their MicroG counterparts) and 4 NLP providers. In Magisk mode, they won't be removed from system, and if you uninstall the pack, they'll come back. If you install in system, the debloated stuff will be stored in internal-storage/MinMicroG/Backup.
WARNING: This zip does not and never will debloat anything else because that is the minimum coming in MicroG's way. I have had my own share of PTSD with debloating. I believe (through guesswork) that it should work even on flashes over gapped ROMs, but don't take my word for it. Debloat before you flash.

For support:
If you flashed through recovery, provide its logs.
If you used Magisk Manager, provide its logs.

How to control the zip by changing its name:
NOTE: Control by name is not possible in magisk manager, since it copies the zip to a cache directory and renames it install.zip. This is unavoidable behaviour.

- Add 'system' to its filename to force it to install/uninstall from system. Otherwise, it looks for magisk, and if not found, installs to system. Obviously, if you flash it through Magisk manager, you want to install it to Magisk. If not, you have to flash it through recovery.

- Add 'uninstall' to its filename to uninstall it from your device, whether in magisk mode or system mode. If you use Magisk Manager, your preffered method of uninstallation is from there.

Just rename it and flash it again for the intended effect.

NOTE: 
- MicroG showing wrong signature for Phonesky? Lemme guess... System mode? Dirty flashed? Go to shell and type (ofcourse with su): 
pm grant com.android.vending android.permission.FAKE_PACKAGE_SIGNATURE
- Dirty flashing not recommended. you'll mess up all your permissions and may even cause conflicts in app data, leading to crashes. 
The maker does not support or endorse dirty flashing. It will harm you and your loved ones. Don't come complaining to me.

Thanks to @osm0sis for the base magisk/recovery code and inspiration and guidance on the majority of the stuff in here. You're awesome.
Thanks to @Setialpha, the creator of NanoDroid, and ale5000 for the lib installation code and permissions code.
