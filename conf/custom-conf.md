# Custom pack guide

The MinMicrog update, build, and install scripts were written with one primary goal in mind: To be completely abstracted from any files being processed using it (of course, along with being fast and widely supported), which is its primary advantage in use cases over any other similar Android flashable mods (besides helping me in staying lazy). What is being installed doesn't matter to the installer; All it needs are a few variables in a text file telling it what files to do stuff to and it'll do its job (as smartly as I could think of). What all this means, my dear fellow, is that you can whip up a quick conf file to make MinMicroG build any kind of flashable zip within minutes.

To prove this, we're gonna write a new config and resdl-download file for an entirely new and relatively simple pack: the AuroraServices package containing just AuroraServices along with a perm file.

If you've read through this document (or perhaps want to play Russian roulette with rm and your device), there is a blank config file in defconf-dummy.txt that you can fill in.

### update.sh and resdl-download.txt
First, before making a pack, we gotta get the Aurora APK files from somewhere. We could've just downloaded and put them in the res directory, but they'd need to be updated and I'm lazy, so no.

What update.sh does for me is get everything I would need for a pack itself from a list of predefined sources and puts them in their proper places in the resdl directory so the build script picks them up. Now, update.sh knows what to get by executing and getting the variables from resdl-download.txt (open it and see) in the conf directory, so we're gonna add a few lines to it to get the three Aurora APKs downloaded automatically when we run the script.

We could get them from FDroid, but their releases are usually out of date and I trust Whyorean so we're gonna grab them from his GitLab page. Fortunately, he has precompiled binaries on his releases page.

Now, we don't need any new FDroid repo for this, so we leave the stuff_repos list untouched. But we're gonna change stuff_download.

For AuroraServices, we'll be keeping the file at path /system/priv-app/AuroraServices/AuroraServices.apk (inside resdl). The URL for the project is https://gitlab.com/AuroraOSS/AuroraServices at the official gitlab server, so our source type is 'gitlab' and source path is 'AuroraOSS/AuroraServices'. So we add the line:
```
  /system/priv-app/AuroraServices/AuroraServices.apk    gitlab  AuroraOSS/AuroraServices

```
To stuff_download.

But ding-ding! When you run the script, you may or may not notice that you may or may not get a valid APK file as the result. Why is that? open AuroraServices's GitLab releases page for yourself and see. The problem is that Whyorean provides a Flashable zip with each release too! How considerate. But that's a problem for the script, because as you may or may not have seen, our poor update.sh can get confused between different files in a release, and we can't exactly blame it; It has no way to know what we wanted and what we got are different, it's simply grabbing the latest file from a release's attachments.

Fortunately, I am wise. I foresaw this situation, and so I added a way to filter through the release files from a GitLab page. All we have to do is add a '.apk' in the fourth column, so that update.sh will first filter all the release attachments into only those having .apk at the end, and then grab the latest of them. So what we have to change that entry into is:
```
  /system/priv-app/AuroraServices/AuroraServices.apk    gitlab  AuroraOSS/AuroraServices    .apk
```
Note that while here I am using a simple suffix for this filtering since there are no other APKs to be confused by, you can also use a more complicated perl-style regex like 'AuroraServices-v[.1-9]*.apk' to protect against future additional APKs in the releases.
Also note that exact same behaviour applies to the fourth column for the 'github' source type.
Additionally note that the fourth column for the 'repo' source type has a different function but similar purpose; It is the architecture and minimum SDK level to filter all the available APKs by.

Now, when we run update.sh, as long as the internet is still up, we will get a correct AuroraServices.apk where we wanted.

### build.sh and defconf-aurora.txt

For a new pack, we make a new defconf file. Note that the name in the defconf file is only used to execute the build command, the name of the zip in releases will be using the variant variable in the defconf. Open the defconf-aurora.txt file and see what the final result is.

NOTE: I only reccomend doing this if you're familiar with shell scripts. DO NOT execute anything directly in the file; it is executed at both build time and flash time, so I hope it's obvious that's a bad idea.

 - First, we set the variant variable to AuroraServices.

 - Then, we set ver, verc, and date to the correct values, considering that verc has to be an integer.

 - Since Services only supports lollipop and above, we set minsdk to 21.

 - Then we fill up the empty values in modprop, seeing as id has to be the modname defined in update-binary, and the Magisk module template is at 1900.

 - Since we have only two files (I wrote up the perm file) to be installed and they both are the same for various architectures and SDKs, we just add them to stuff.
(To understand how the others like stuff_arch and stuff_sdk work, I'd reccomend running update.sh and looking at the keyboard swipe and contact sync files.)

 - They don't have anything they conflict with, so nothing to add to stuff_debloat.

 - We need to add permissions to the two files, so we add their respective directories to stuff_perm.

 - A service/init.d script is not really useful to us for this package, so we leave it blank.

 - While an addon.d script might be useful, I ommitted it for simplicity in this file.

 - We don't have anything special to do with this package, so nothing in the build or install functions. But we don't remove the functions completely, that would cause an error.

There, we have the config file for our brand new AuroraServices pack!

### Build it

Execute
```
> ./build.sh aurora
```

And you should find a AuroraServices pack in the releases directory.
