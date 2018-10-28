<p align="center">
<h2 align=center> Detach </h3>

<p align="center">
 <a href="https://forum.xda-developers.com/android/software-hacking/mod-detach-market-links-theme-ready-apps-t3447494"><img src="https://img.shields.io/badge/XDA-Thread-yellow.svg?longCache=true&style=flat-square"></a><br />
 <a href=https://t.me/joinchat/ElFVDxJDgCkDt5Zr_qblGQ"><img src="https://img.shields.io/badge/Telegram-Channel-blue.svg?longCache=true&style=flat-square"></a></p><br />

<h3 align=center>Introduction</h3>
<h4 align=center>This Module is a portage of the original MOD created by hinxnz - <a href="https://forum.xda-developers.com/member.php?u=1909299">XDA thread/OP</a> to works as a Magisk module for Android, so all credits to him/her<h4>

<h4>Short explanation:</h4>
<h5>With this MOD, you can "detach" app(s) from Google Play Store automatic update, it completly hide the update in the "My games and applications", so no more boring Play Store notification about an update available for your selected app(s)!<br /></h5>

<br />
<h3>=> For Google common's apps:</h3>
- You have to download the following file: <a href="https://forum.xda-developers.com/attachment.php?attachmentid=4141103&d=1494126907">detach.txt</a>
- Saving it on root of your storage like that:

![screen1](https://image.ibb.co/kDxwoA/Screenshot-20181025-211140.png)<br />

<h3>=> As writed</h3>
 - uncomment the app(s) you want to "hiding" from Play Store updates:

![screen2](https://image.ibb.co/kCBd1V/Screenshot-20181025-211255.png)<br />

<h3>=> For any over apps available on the Play Store:</h3>
- You have to download the following file: <a href="https://forum.xda-developers.com/attachment.php?attachmentid=4141081&d=1494123950">detach.custom.txt</a>
- Saving it on root of your storage like that:

![screen3](https://image.ibb.co/mV1kMV/Screenshot-20181028-201636.png)<br />

- Write your app(s) package(s) name(s) one by line
(like the following exemple below)

![screen4](https://image.ibb.co/hL1kMV/Screenshot-20181028-201657.png)<br />

<b>Common: Question and Answers:</b>

Q:A problem ?
A:Ask on XDA OP (scroll up) or/and on Telegram group

Q:When changes are applied ?
A:You must to reboot your device to apply any changes

Q:Apps aren't "hide" in my Play Store!
A:Try to flash again the module by custom Recovery (CWM,TWRP,..)

Q:How to "attach" again an app who is previously "hided" ?
A:For now, just remove the package name in '/sbin/.core/img/Detach/service.sh', i work to implement this feature :)

Q:Compatibility ?
- Magisk v17 and newer
- All Android/Devices/Archs supported
- Substratum themes for Play Store

Q:What does this module do ? Does touch the system partition ?
A:It only edit an SQL database file in Play Store folder on your /data partition

Q:Just after reboot, all unwanted apps stay in my Play Store updates
A:Just wait 1 minute before the Magic appear!

Q:My Play Store history search will be deleted ?
A:No no, why ask that ?
