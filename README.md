<p align="center">
<h2 align=center> Detach </h3>

<p align="center">
 <a href="https://forum.xda-developers.com/android/software-hacking/mod-detach-market-links-theme-ready-apps-t3447494"><img src="https://img.shields.io/badge/XDA-Thread-yellow.svg?longCache=true&style=flat-square"></a><br />
 <a href=https://t.me/Detach_gms_apps><img src="https://img.shields.io/badge/Telegram-Channel-blue.svg?longCache=true&style=flat-square"></a></p><br />

<h3 align=center>Introduction</h3>
<h4 align=center><b>INFO:</b>This Module is a port of the original MOD created by hinxnz - <a href="https://forum.xda-developers.com/member.php?u=1909299">XDA thread/OP</a> to work as a Magisk module for Android, so all credits to him. :+1:<h4>
<br />
 
<h4>:information_source: Short explanation:</h4>
<h5>With this MOD, you can "detach" app(s) from your Google Play Store automatic update process, it completely hides the update in the "My games and applications" section. So you won't see your detached apps from your Play Store pending updates!<br /></h5>
<br />

<b>:scroll: Setup steps:</b>
- If you just want to detach common app(s) like Hangouts, YouTube, Facebook, etc, just download the <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/detach.txt">detach.txt</a> file and save it in your `/sdcard/` folder.
- If you want to detach some specific apps, so download the <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/detach.custom.txt"> detach.custom.txt</a> file and save it in your `/sdcard/` folder.
- Make sure that the file(s) detach.txt and/or detach.custom.txt are in your `/sdcard/` folder.
- Flash the module ZIP (Magisk Manager and TWRP are supported)
- Done!
<br />

<b>:heavy_check_mark: Compatibility:</b>
- Magisk (v15 to lastest)
- All Android devices from Lollipop to Pie
- Magisk Manager & TWRP
- Substratum themes for Play Store
- Scheduling
<br />

------------------------------------------------------------------------------------

<h5>:warning: <b>Warning</b>: In a very few cases, this mod can purely break the Play Store app, so please backup your phone before flashing this mod. Thanks for your understanding.</h5>

------------------------------------------------------------------------------------

#### :bulb: Terminal features:
- Instant detaching: instantly detaching your favorites app(s)
- Add app(s): detach new app(s)
- Remove app(s): attach again app(s) to Play Store updates
- Kill: killing Play Store application
- Clear Play Store data: clear the Play Store's app data
- Task scheduler: automaticaly setup a task scheduler to automaticaly detach your app(s) from the Play Store's updates
- Silent mode: enable or disable the silent mode, to have cleaner and less cluttered order results
- Busybox compatibility check
- Help: a help menu with all possible commands explained in detail

------------------------------------------------------------------------------------

<br />
<h3><u>For common apps:<u></h3>
- You have to download the following file: <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/detach.txt" ">detach.txt</a> 
 
- Save it in your phone's internal storage root:<br />
(So: `/sdcard/detach.txt` or `/storage/emulated/0/detach.txt`)

<img src="https://i.ibb.co/17hMqx6/Screenshot-20190815-170758.png" alt="Screenshot-20190815-170758.png" height="1200" width="600"><br />
<br />
<h4>- As file's instructions:</h4>
 - uncomment the app(s) you want to "hide" from Play Store updates:<br />

<img src="https://i.ibb.co/SxFqK9W/Screenshot-20190815-170841.png" alt="Screenshot-20190815-170841.png" height="1200" width="600"><br />

------------------------------------------------------------------------------------

<br />
<h3><u>For any other apps:<u></h3>
- You have to download this file: <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/detach.custom.txt" "> detach.custom.txt</a>
 
- Saving it on root of your internal storage as before:<br />
(So: `/sdcard/detach.custom.txt` or `/storage/emulated/0/detach.custom.txt`)

- Type your app(s) package(s) name(s), one per line and let a blanck line at the end. For example:<br />

<img src="https://i.ibb.co/XyS3kFF/Screenshot-20190815-170905.png" alt="Screenshot-20190815-170905.png" height="1200" width="600"><br />
<br />
<br />

### :grey_question: <b>Common Question and Answers:</b>

#### Q: A problem ?

A: Ask on Telegram group or/and on XDA OP (scroll up)

#### Q: When are the changes applied ?

A: When you flash the module, and when you run the command: su -c detach -id.

#### Q: Where to find an app's package name ?

A: App's package name is in the middle of the two texts framed in grey<br />
`https://play.google.com/store/apps/details?id=`com.package.name`&hl=en`

#### Q: Apps aren't hidden in my Play Store!

A: If you have already run the command (`su -c -detach -id`), report on the Telegram group.<br />

#### Q: How to "attach" again an app who is previously "hidden" ?

A:  Just comment again the app name in the detach.txt file or delete the corresponding package name in the detach.custom file and wait some minutes/hours. Or you can remove Play Store's app data, but you will lose your Play Store update history.

#### Q: What does this module do? Does it touch the system partition ?

A: It only edits a SQL database file in Play Store folder on your `/data` partition. Nothing more, nothing less.

#### Q: After several hours, my detached app(s) are back in my Play Store, what's wrong ?

A: With a recent update of the Play Store, an unknow wakeloks refresh the SQL database file of the Play Store.
To fix it: just install a Terminal Emulator app or Termux (or another terminal emulator app) and run the command:
=> `su -c detach -id`

#### Q: My Play Store history search will be deleted ?

A: <b>ONLY</b> if you select the 'c' option in the terminal menu (as indicated in the menu).

#### Q: Is it possible to add or remove app(s) from the module's setup ?

A: Yes! See below:
- For adding:
    - `su -c detach -a` (or `su -c detach --add-app`)

- And for removing:
    - `su -c detach -r` (or `su -c detach --rem-app`)

#### Q: And if I'm too lazy to do the detach command every time the Play Store updates its file?

A: You can schedule the `su -c detach -id` command
- To do this, just do:
    - Run `su -c detach -t` (or `su -c detach --task-scheduler`) command in your terminal
    - Choose a way.


------------------------------------------------------------------------------------

Here we go ? :relaxed:
