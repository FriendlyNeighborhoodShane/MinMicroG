# Install Guide

**Where I force my opinions on you**
**Kanged from the NoGoolag Telegram group and microG subreddit**

### Instructions for installation

##### Chapter 1: ROM
You can skip this if you have the ROM set up already, but it's highly recommended to start with a clean install.
 - Wipe or format data from your custom recovery.
 - Flash your clean ROM and any other system mods you may want.

##### Chapter 2: microG
You can install MinMicroG as a Magisk module or directly to the system. If you install as a module, it will not touch system at all, and you can easily remove it when something goes wrong. On the other hand, it will be tied to the Magisk installation and can be removed with it.
 - If you want MinMicroG to be installed as a Magisk module, flash Magisk and boot your phone once to allow Magisk to setup properly.
 - Flash MinMicroG, preferably from recovery.
 - Open microG Settings > Self-Check. If "System grants signature spoofing permission" isn't ticked, click on it and grant the permission.
 - In microG settings, Go to "Google device registration", "Google Cloud Messaging" and enable both of them.
 - If you wish to connect to your Google account, go to Settings > Accounts > Add Accounts > Google and login to your account.
 - Reboot.

##### Chapter 3: UnifiedNLP
 - In microG settings, go to UnifiedNLP settings, and enable every backend you want in "Configure location backends" and "Configure address lookup backends".
 - Open gear icons on the backends that have it and grant all neccessary permissions and configuration.
 - Reboot.

Most of your self-check should be checked by now. If the last one or two are not, just enable high accuracy location, open the map tab on Satstat (from FDroid) and wait until a blue circle appears. They should be okay now.

### Prerequisites

##### [microG] Signature spoofing
Sigspoofing is a feature that is required by several core features of MicroG, namely those that require pretending to be the real Google Play Services.

All apps basically call Play Services like, "Yo, package com.google.android.gms with signature x, I need this done". So for microg to receive that message, microg needs to have the same signature.

But since we don't have google's keys to sign the microg apk with the same signature as gapps, we add an extra feature in Android that makes microg look like it has the play services signature. The app asks, "Hey Android, is this really play services?" Android responds <crossing its fingers>, "Yeah, sure".

Of course, this is only a simplified explanation. To be more technically accurate, it patches Android's signature checking mechanism at the core, meaning it can be used for installing over different signatures too.

Because the permission has the possibility to be misused, several ROM maintainers (including LOS) have rejected putting sigspoof in the official code. But most of them have rejected it just because they are averse to trying to leave Google. Some ROMs that do include sigspoof in official builds are:
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
 - Patching it with Haystack patcher or Needle patcher
   - Requires PC
 - Using the NanoDroid-patcher standalone zip for on-device patching
   - Fork of Haystack modified to run on-device
 - Using an Xposed module called FakeGapps
 - Using the SmaliPatcher application on PC (shrouded in mystery)
   - Proprietary, windows only
   - [Here](https://forum.xda-developers.com/showpost.php?p=78958124) OP of XDA thread admits they do not know of the source code, probably do not even have access to it
   - [Here](https://forum.xda-developers.com/showpost.php?p=80287799), [Here](https://forum.xda-developers.com/showpost.php?p=80287989), [Here](https://forum.xda-developers.com/showpost.php?p=80292041), It connects to arbitrary Russian IPs and OP says it's probably nothing

You also need to watch which apps you grant sigspoof permissions to. I am not aware of any app that legitimately requires sigspoof other than MicroG.

##### [microG and UNLP] Network Location Provider support
Another major thing MicroG and UNLP do is providing network location to apps.

What is network location? It's a quick and rough estimate of your location, several hundred metres wide, made using cellular towers and wifi networks around you, before you get a precise GPS lock. Basically it's the wider circle that appears on your maps app quickly before a smaller accurate one appears.

It technically should not be needed for the functioning of most apps, but poorly coded ones that depend on Google Play Services often crash without it.

Most ROMs should support it, but some OnePlus's and Xaiomi's have other providers (like com.qualcomm.location) that do not allow other providers to bind with system.

Ask maintainer to apply this patch if UNLP doesn't bind on your N+ ROM:
https://github.com/microg/android_packages_apps_UnifiedNlp/blob/master/patches/android_frameworks_base-N.patch
Also make sure your the ROM looks for com.google.android.gms as a location provider.

##### No preinstalled GApps, obviously
MinMicroG does a little debloating that may even make it work on GApps-infected ROMs, but I've never tested and give no guarantees. (Well I don't give guarantees for clean ROMs either, but that'a a different thing)

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
If multiple reboots do not solve this, some other provider might be overriding it, like com.qualcomm.location. Debloat them. If that doesn't solve it, your ROM may require source-level patches, detailed in the prerequisites section.

##### Misc network location problems
I should take these two paragraphs to clarify that Network location is NOT GPS. microG has nothing to do with your GPS. Network Location is that hugely approximated wide-circle that appears before you get a GPS Lock.

If you cannot get a location even on device only location mode, it's not microG. It's your app, your ROM, your device, or your cursed house. Change any of these.

To test network location, enable high accuracy location, and then use satstat (from FDroid), open maps tab and wait for the blue circle to appear.

If it doesn't, there's a problem with UNLP.

##### Permission troubles with microG and gang
In a terminal app (like Termux) write these 2 commands, accept root request and reboot:
```
su;
npem;
```

##### GCM/FCM push messaging
Go to microG settings > Google Cloud Messaging and check if the app is connected.

if no:
 - Try wiping data for the app
 - Before restoring a backup, first restore the app only (without data) and start it to register the app. After that you can restore the data.

If yes:
 - Ensure you don't have an adblocker blocking the domain, whitelist it in adaway and similar:
mtalk.google.com

If you can't get any app to register for Google Cloud Messaging, try dialing this:

\*\#\*\#2432546\#\*\#\*
or
\*\#\*\#CHECKIN\#\*\#\*

##### Play Store RH-01 error
Go to System > Apps > Play Store
 - Force stop
 - Clear storage
 - Grant all permissions (make sure sigspoof is)

If even that doesn't work:
 - Settings > System > Accounts > Remove Google Account
 - System > Accounts > Disable Account Data Synchronization
 - After all is set in microG self-test after doing the above steps, open Play Store and re-add your account.
 - You may have to close (recent apps > swipe it away) the Play Store once

Et voila, it (hopefully) works properly again.

### Alternatives and Suggestions

##### Contact sync
The standard package includes sync adapters that work automatically after logging in and turning on device registration.

But giving all your contacts to Google is not on the "top 100 ideas of all time" list. You should probably look into selfhosting.

You can retieve your contacts directly from your Google account in a vcf file:
 - Go to https://contacts.google.com/ and login
 - Use sidebar > Export > select 'Export as VCard' > Export

You should also be able to sync contacts with Google without proprietary apps or microG using the open-source CardDAV client DAVdroid (available on F-Droid or Play)
 - First of all, go to https://www.google.com/settings/security/lesssecureapps
With your account and enable the setting
 - When logging in with DAVDroid, Use "Login with URL and user name"
   - Base URL: https://www.google.com/calendar/dav/your_gmail_id@gmail.com/events
   - User name: your_gmail_id@gmail.com
   - Password: Your Google account password

##### Android Wear companion apps
 - https://f-droid.org/app/nodomain.freeyourgadget.gadgetbridge
 - AsteroidOS and similar projects

##### Making miscelleneous Google Apps work
If they don't log into an account, try force stop and wipe data. Or perhaps logging out of all Google accounts, and logging in from inside the app's prompt.

If nothing else works, backing up the app from a working GApps setup and then restoring it should. Stuff like MagicGapps or WeebGApps should be helpful.

##### Making swipe work on AOSP keyboard
If you do not wish to switch to the superior AnySoft keyboard and the swipe libs don't work with AOSP kb on your ROM, try this:
https://forum.xda-developers.com/android/apps-games/enhancedime-aosp-latinime-enhancements-t3366639
