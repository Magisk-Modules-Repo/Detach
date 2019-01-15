<p align="center">
<h2 align=center> Detach </h3>

<p align="center">
 <a href="https://forum.xda-developers.com/android/software-hacking/mod-detach-market-links-theme-ready-apps-t3447494"><img src="https://img.shields.io/badge/XDA-Thread-yellow.svg?longCache=true&style=flat-square"></a><br />
 <a href=https://t.me/joinchat/ElFVDxJDgCkDt5Zr_qblGQ"><img src="https://img.shields.io/badge/Telegram-Channel-blue.svg?longCache=true&style=flat-square"></a></p><br />

<h3 align=center>Introduction</h3>
<h4 align=center>This Module is a portage of the original MOD created by hinxnz - <a href="https://forum.xda-developers.com/member.php?u=1909299">XDA thread/OP</a> to works as a Magisk module for Android, so all credits to him/her<h4>

<h4>Short explanation:</h4>
<h5>With this MOD, you can "detach" app(s) from Google Play Store automatic update, it completly hide the update in the "My games and applications", so no more boring Play Store notification about an update available for your selected app(s)!<br /></h5>

------------------------------------------------------------------------------------

<h5><b>Warning</b>: In a minority of cases, this MOD can purely break the Play Store app, so please backup your phone before setup this MOD on your phone. Thank you for your understanding.</h5>

------------------------------------------------------------------------------------

## 2 ways to add apps in hiding feature:
- <b>Detach.txt</b> file for <b>Google common's apps</b> and some others
- <b>detach.custom</b> file for any other apps

<br />
<h3>For Google common's apps:</h3>
- You have to download the following file:<a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/detach.txt" ">detach.txt</a> 
- Saving it on root of your storage like that:<br />

<img src="https://image.ibb.co/kDxwoA/Screenshot-20181025-211140.png" alt="Screenshot-20181025-211140.png" height="1200" width="600"><br />
<br />
<h3>=> As writed</h3>
 - uncomment the app(s) you want to "hiding" from Play Store updates:<br />

<img src="https://image.ibb.co/kCBd1V/Screenshot-20181025-211255.png" alt="Screenshot-20181025-211255.png" height="1200" width="600"><br />

<br />
<h3>For any over apps:</h3>
- You have to download this file: <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/detach.custom.txt" ">detach.custom.txt</a>
- Saving it on root of your storage like that:<br />

<img src="https://image.ibb.co/mV1kMV/Screenshot-20181028-201636.png" alt="Screenshot-20181028-201636.png" height="1200" width="600"><br />

- Write your app(s) package(s) name(s) one by line
(like the following exemple below)<br />

<img src="https://image.ibb.co/hL1kMV/Screenshot-20181028-201657.png" alt="Screenshot-20181028-201657.png" height="1200" width="600"><br />
<br />
<br />
<b>Common: Question and Answers:

Q:A problem ?

A:Ask on XDA OP (scroll up) or/and on Telegram group

Q:When changes are applied ?

A:You must to reboot your device to apply any changes

Q:Apps aren't "hide" in my Play Store!

A:Try to flash again the module by custom Recovery (CWM,TWRP,..)<br />

Q:How to "attach" again an app who is previously "hided" ?

A:Removing Play Store app datas can help with a reboot. Or just remove the `/sbin/.magisk/img/Detach/service.sh` file, i work to implement this feature :)

Q:Compatibility ?
- Magisk v18 and newer
- All Android/Devices/Archs supported
- Substratum themes for Play Store

Q:What does this module do ? Does touch the system partition ?

A:It only edit an SQL database file in Play Store folder on your /data partition. No more, no less.

Q:Just after reboot, all unwanted apps stay in my Play Store updates

A:Just wait 1 minute before the Magic appear!

Q: After several hours, my detached app(s) are back in my Play Store, what's wrong ?

A: With a recent update of the Play Store, an unknow wakeloks refresh the SQL database file of the Play Store. To fix it, just install Terminal Emulator or Termux (or another terminal emulator app) and type:
- su
- Detach

(2 other options has been added into the menu but use them <b>ONLY</b> if you know what you want !)

Q:My Play Store history search will be deleted ?

A:<b>ONLY</b> if you select the 'c' option in the terminal menu (as indicated in the menu)
