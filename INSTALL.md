# Install Guide

**Where I force my opinions on you**

**Kanged from the NoGoolag Telegram group and microG subreddit**

### Instructions for installation

##### Chapter 1: ROM
You can skip this if you have the ROM set up already, but it's highly
recommended to start with a clean install.
 - Wipe or format data from your custom recovery.
 - Flash your clean ROM and any other system mods you may want.

##### Chapter 2: microG
You can install MinMicroG as a Magisk module or directly to the system. If you
install as a module, it will not touch system at all, and you can easily remove
it when something goes wrong. On the other hand, it will be tied to the Magisk
installation and can be removed with it.
 - If you want MinMicroG to be installed as a Magisk module, flash Magisk and
   boot your phone once to allow Magisk to setup properly.
 - Flash MinMicroG, preferably from recovery.
 - Open microG Settings > Self-Check. If "System grants signature spoofing
   permission" isn't ticked, click on it and grant the permission.
 - In microG settings, Go to "Google device registration", "Google Cloud
   Messaging" and enable both of them.
 - If you wish to connect to your Google account, go to Settings > Accounts >
   Add Accounts > Google and login to your account.
 - Reboot.

##### Chapter 3: UnifiedNLP
 - In microG settings, go to Location modules, and enable every backend you
   want in "Network-based geolocation modules" and "Address lookup modules".
 - Open gear icons on the backends that have it and grant all neccessary
   permissions and configuration.
 - Reboot.

Most of your self-check should be checked by now. If the last one or two are
not, just enable high accuracy location, open the map tab on Satstat (from
FDroid) and wait until a blue circle appears. They should be okay now.

### Prerequisites

##### [microG] Signature spoofing
Sigspoofing is a feature that is required by several core features of MicroG,
namely those that require pretending to be the real Google Play Services.

All apps basically call Play Services like, "Yo, package
`com.google.android.gms` with signature `x`, I need this done". So for microg
to receive that message, microg needs to have the same signature.

But since we don't have google's keys to sign the microg apk with the same
signature as gapps, we add an extra feature in Android that makes microg look
like it has the play services signature. The app asks, "Hey Android, is this
really play services?" Android responds <crossing its fingers>, "Yeah, sure".

Of course, this is only a simplified explanation. To be more technically
accurate, it patches Android's signature checking mechanism at the core.
Because of that, apps can misuse the permission and compromise your device by
allowing APKs from different (possibly malicious) creators to be installed over
the current one.

ROMs with a source sigspoof patch are much less dangerous in this regard
because they have sigspoofing as a part of the Android runtime permissions GUI,
as opposed to dexpatched ROMs, which grant it universally without any user
consent. Regardless, you should carefully watch who you grant sigspoof to, and
how you update that app. I am not aware of any app that legitimately requires
sigspoof other than microG, fakestore, and patched Playstore.

Because the permission has the possibility to be misused, several ROM
maintainers (including LOS) have rejected putting sigspoof in the official
code. But most of them have rejected it just because they are averse to trying
to leave Google. Some ROMs that do include sigspoof in official builds are:
 * LOS for µG
 * AEX
 * AospExtended
 * AOSIP
 * ArrowOS
 * CarbonROM
 * NitrogenOS
 * OmniROM

There are several other ways to have your ROM support sigspoof too:
 - Patching it at the source level
   - Easiest if you self-build or know a friendly neighborhood maintainer
   - Patches in microG repo
   - OmniROM's commits to integrate it into Android's permissions GUI
     [here](https://gerrit.omnirom.org/c/android_packages_apps_PackageInstaller/+/36730)
     and [here](https://gerrit.omnirom.org/c/android_frameworks_base/+/36729)
 - Patching it with Haystack patcher or Needle patcher
   - Requires PC
 - Using the NanoDroid-patcher standalone zip for on-device patching
   - Fork of Haystack modified to run on-device
 - Using an Xposed module called FakeGapps

##### [microG and UNLP] Network Location Provider support
Another major thing MicroG and UNLP do is providing network location to apps.

What is network location? It's a quick and rough estimate of your location,
several hundred metres wide, made using cellular towers and wifi networks
around you, before you get a precise GPS lock. Basically it's the wider circle
that appears on your maps app quickly before a smaller accurate one appears.

It technically should not be needed for the functioning of most apps, but
poorly coded ones that depend on Google Play Services often crash without it.

Most ROMs should support it, but some OnePlus's and Xaiomi's have other
providers (like `com.qualcomm.location`) that do not allow other providers to
bind with system.

If UNLP doesn't bind on your N+ ROM:
 - Ask maintainer to apply this
   [patch](https://github.com/microg/android_packages_apps_UnifiedNlp/blob/master/patches/android_frameworks_base-N.patch)
 - Make sure your the ROM looks for `com.google.android.gms` as a location
   provider

##### No preinstalled GApps, obviously
MinMicroG does a little debloating that may even make it work on GApps-infected
ROMs, but I've never tested and give no guarantees. (Well I don't give
guarantees for clean ROMs either, but that'a a different thing)

Get a clean AOSP-based ROM.

Or if you're a masochist, there are several ways to clean those kinds of ROMs:
 - Gapps removal script
   - https://github.com/CHEF-KOCH/Remove-Gapps
 - G-Killer (GAPPS aroma Debloater)
   - https://forum.xda-developers.com/android/software-hacking/aroma-google-services-debloater-t3668456
 - Rom Cleaner
   - https://github.com/DroidTR/Rom-Cleaner
 - /d/gapps
   - https://f-droid.org/app/org.droidtr.deletegapps


### Troubleshooting

##### Not registered as system location provider
If multiple reboots do not solve this, some other provider might be overriding
it, like `com.qualcomm.location`. Debloat them. If that doesn't solve it, your
ROM may require source-level patches, detailed in the prerequisites section.

##### Misc network location problems
I should take these two paragraphs to clarify that Network location is NOT GPS.
microG has nothing to do with your GPS. Network Location is that hugely
approximated wide-circle that appears before you get a GPS Lock.

If you cannot get a location even on device only location mode, it's not
microG. It's your app, your ROM, your device, or your cursed house. Change any
of these.

To test network location, enable high accuracy location, and then use satstat
(from FDroid), open maps tab and wait for the blue circle to appear.

If it doesn't, there's a problem with UNLP.

##### Permission troubles with microG and gang
Run this command from any terminal app (like Termux) after `su`, or from a
computer after `adb shell`, and then reboot:
```
npem;
```

Some new permissions are protected by Android now, and cannot simply be
granted. You can try several things that may or may not work, depending on your
ROM:
 - Extracting the MicroG APK from the zip
   (`system/priv-app/MicroGGMSCore/MicroGGMSCore.apk`) and installing it as an
   user app update (`npem` tries this for you automatically)
 - Installing MinMicroG as system instead of as a Magisk module
 - Clean flashing, if all else fails

##### GCM/FCM push messaging
Go to microG settings > Google Cloud Messaging and check if the app is
connected.

if no:
 - Try wiping data for the app
 - Before restoring a backup, first restore the app only (without data) and
   start it to register the app. After that you can restore the data.

If yes:
 - Ensure you don't have an adblocker blocking the domain, whitelist it in
   adaway and similar: `mtalk.google.com`

If you can't get any app to register for Google Cloud Messaging, try dialing
this:

`*#*#2432546#*#*` or `*#*#CHECKIN#*#*`

If you restored app data from old backups, there might be some configuration
files left over preventing the app from registering for push with microG. Run
this from a root terminal:

```
rm -rf /data/data/*/shared_prefs/com.google.android.gms.*.xml
```

##### Play Store RH-01 error
Go to System > Apps > Play Store
 - Force stop
 - Clear storage
 - Grant all permissions (make sure sigspoof is)

If even that doesn't work:
 - Settings > System > Accounts > Remove Google Account
 - System > Accounts > Disable Account Data Synchronization
 - After all is set in microG self-test after doing the above steps, open Play
   Store and re-add your account.
 - You may have to close (recent apps > swipe it away) the Play Store once

Et voila, it (hopefully) works properly again.

### Alternatives and Suggestions

##### Contact sync
The standard package includes sync adapters that work automatically after
logging in and turning on device registration.

But giving all your contacts to Google is not on the "top 100 ideas of all
time" list. You should probably look into selfhosting.

You can retieve your contacts directly from your Google account in a vcf file:
 - Go to [Google Contacts](https://contacts.google.com) and login
 - Use sidebar > Export > select 'Export as VCard' > Export

You should also be able to sync contacts with Google without proprietary apps
or microG using the open-source CardDAV client DAVx5 (available on F-Droid or
Play)
 - Go to Google Dashboard's
   [app passwords](https://myaccount.google.com/apppasswords) page, and create
   an app password if you don't have one already
 - When logging in with DAVx5, Use "Login with URL and user name"
   - Base URL:
     `https://www.google.com/calendar/dav/[your_gmail_id]@gmail.com/events`
   - User name: `[your_gmail_id]@gmail.com`
   - Password: `[your_app_password]`

##### Android Wear companion apps
 - GatgetBridge companion app on F-Droid
 - AsteroidOS and similar projects

##### Making miscelleneous Google Apps work
If they don't log into an account, try force stop and wipe data. Or perhaps
logging out of all Google accounts, and logging in from inside the app's prompt.

If nothing else works, backing up the app from a working GApps setup and then
restoring it should. Stuff like MagicGapps or WeebGApps should be helpful.

##### Paid apps, license verification and IAPs
You can directly buy apps from the Play Store if you have it installed with
microG. But if you don't, a much cleaner way is to buy it from the
[Google Play](https://play.google.com) website through a browser.

If you've bought an app, you can download it without Play Store by using Aurora
Store by logging in with your own account.

License verification, unfortunately, is something tied to Play Store and
probably always will be. If you don't want to install it, all you can do is
pester the devs to remove it or atleast offer alternative means of verification.
 - The Titanium Backup devs are a bunch of nice people. If you email them,
   they'll give you offline verification codes.

In App Purchases are even more tied to Play Store. Not even vanilla Play Store
will do, it has to be patched for sigspoofing to be able to use IAPs. Setialpha
regularly grabs the latest release and patches it, and the product can be found
in the NanoDroid F-Droid repository.

##### Making swipe work on AOSP keyboard
If you do not wish to switch to the superior AnySoft keyboard and the swipe
libs don't work with AOSP kb on your ROM, try this:
https://forum.xda-developers.com/android/apps-games/enhancedime-aosp-latinime-enhancements-t3366639
