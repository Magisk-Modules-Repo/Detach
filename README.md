<p align="center">
<h2 align=center> Detach </h3>

<p align="center">
 <a href="https://forum.xda-developers.com/android/software-hacking/mod-detach-market-links-theme-ready-apps-t3447494"><img src="https://img.shields.io/badge/XDA-Thread-yellow.svg?longCache=true&style=flat-square"></a><br />
 <a href=https://t.me/Detach_gms_apps><img src="https://img.shields.io/badge/Telegram-Channel-blue.svg?longCache=true&style=flat-square"></a></p><br />

<h3 align=center>Introduction</h3>
<h4 align=center><b>INFO:</b>This Module is a port of the original MOD created by hinxnz - <a href="https://forum.xda-developers.com/member.php?u=1909299">XDA thread/OP</a> to work as a Magisk module for Android, so all credits to him. :+1:<h4>
<br />
 
<h4>:information_source: Short explanation:</h4>
<h5>With this MOD, you can "detach" app(s) from your Google Play Store automatic update process, it completely hides the update in the "My games and applications" section. So you won't see your detached apps from your Play Store pending updates!
You can access the simple mode by put a simple file `simple_mode.txt` in your `/sdcard/` folder and flash the module.<br /></h5>
<br />

<b><h3>:scroll: Setup steps:</h3></b>
- Start by downloading the `Detach.txt` file to your `/sdcard/` folder: <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/Detach.txt">Detach.txt</a>
  - (equivalent to `/storage/emulated/0/`)
- Uncomment the common app(s) you want in this file
- Save changes
- Flash the module ZIP with Magisk Manager
  - Magisk Manager app is required for the flash
- Reboot your device.
- Profit!
<br />
<br />

<b><h3>:sparkler: Bonus: To detach other applications from your Play Store</h3></b>
- Open your `/sdcard/Detach.txt` file on your device
- Write `# Other applications` at the line number 45
- Press your `ENTER` key 1 time to do a new-line (equivalent symbol: `\n`)
- Write the package(s) name(s) of application(s) you want to detach (1 by line)
- Let a blanck line at the end of your file (with your `ENTER` or with the equivalent symbol: `\n`)
- Save changes
- Flash the module again via Magisk Manager
  - Or just do `su -c detach -a` in a terminal emulator (if you already have the module installed)
<br />
<br />

<b>:heavy_check_mark: Compatibility:</b>
- Magisk (v15 to lastest)
- All Android devices from Lollipop to Pie
- Magisk Manager
- Substratum themes for Play Store
- Any Linux text editor (for `LF` line-end usage by default)
- Scheduling
<br />

<b>:page_facing_up: Other Magisk module pre-requisite:</b>
- Busybox for Android NDK
<br />
<br />

------------------------------------------------------------------------------------

<h5>:warning: <b>Warning:</b> In a very few cases, this mod can purely break the Play Store app, so please backup your phone before flashing this mod. Thanks for your understanding.</h5>

------------------------------------------------------------------------------------

:bulb: <b>Terminal features:</b>
- Instant detaching: instantly detaching your favorites app(s)
- List detached app(s): list all your app(s) wich are detached from the Play Store
- Add app(s): detach new app(s)
- Remove app(s): remove detach feature for detached app(s)
- Kill: killing Play Store application
- Clear Play Store data: clear the Play Store's app data
- Task scheduler: Several possibilities to automate the detachment of your application(s) from the Play Store
- Silent mode: enable or disable the silent mode, to have for a cleaner and less cluttered display in your terminal
- Busybox compatibility check and Magisk module auto-installer
- Help: a help menu with all possible commands explained in details

------------------------------------------------------------------------------------
<br />

<b>For common apps:</b>
- You have to download the `Detach.txt` file: <a href="https://raw.githubusercontent.com/xerta555/Detach-Files/master/Detach.txt">Detach.txt</a>
- Save it in your internal storage: `/sdcard/Detach.txt` (quivalent to `/storage/emulated/0/Detach.txt`).
 
<img src="https://i.ibb.co/X54TnPG/Screenshot-20190923-184536.png" alt="Screenshot-20190815-170758.png" height="1200" width="600">
<br />
<br />

<b>As the instructions say:</b>
- Uncomment the app(s) you want to "hide" from Play Store updates
- Save your changes
<br />
<img src="https://i.ibb.co/SxFqK9W/Screenshot-20190815-170841.png" alt="Screenshot-20190815-170841.png" height="1200" width="600"><br />

------------------------------------------------------------------------------------
<br />
<br />

<b>For any other app(s):</b>
- You have to write `# Other applications` at the line 45
- Write the app(s) package(s) name(s) on the next line.
- Don't forget to press your ENTER key when you will have finish to write your custom packages names.
<br />
<h3><b>An exemple:</b></h3>
<br />
<img src="https://i.ibb.co/gTNb8hW/photo-2019-10-17-19-04-41.jpg" alt="Screenshot-20190815-170841.png" height="1200" width="600"><br />
<br />
<br />

### :grey_question: <b>Common Question and Answers:</b>

#### Q: A problem ?

A: Ask on Telegram group or/and on XDA OP (scroll up)

#### Q: When are the changes applied after the first flash ?

A: After you will have reboot your device.

#### Q: And the `detach.custom` file so?

A: Starting from version `4.X`, there is no longer need of this file, you just have to use the `Detach.txt` file.

#### Q: Where to find an app's package name for an another app (custom app) ?

A: App's package name is in the middle of the two texts framed in grey<br />
`https://play.google.com/store/apps/details?id=`com.package.name`&hl=en`

#### Q: Apps aren't hidden in my Play Store!

A: If you have already run the command `su -c detach -id`, report on the Telegram group.<br />

#### Q: How to "attach" again an app who is previously "hidden" ?

A:  Just comment again the app name or the corresponding package name in the `/sdcard/Detach.txt` file and wait some minutes/hours. Or you can remove Play Store's app data, but you will lose your Play Store update and search history.

#### Q: What does this module do? Does it touch the system partition ?

A: It only edits a SQL database file in Play Store folder on your `/data` partition. Nothing more, nothing less.

#### Q: After several hours, my detached app(s) are back in my Play Store, what's wrong ?

A: With a recent update of the Play Store, an unknow wakeloks refresh the SQL database file of the Play Store.
To fix it: just install a Terminal Emulator app or Termux (or another terminal emulator app) and run the command:
=> `su -c detach -id`

#### Q: My Play Store history search will be deleted ?

A: <b>ONLY</b> if you select the `-c` option in the terminal menu (as indicated in the menu).

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
