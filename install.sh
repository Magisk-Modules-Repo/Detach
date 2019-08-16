##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "          Detach          "
  ui_print " Modded by Rom for Magisk"
  ui_print "    All credits to hinxnz"
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH
  unzip -o "$ZIPFILE" sqlite -d $TMPDIR
  ln -sf Detach detach
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $TMPDIR 0 0 0755 0644
  set_perm $MODPATH/system/bin/Detach 0 0 0777
  set_perm $TMPDIR/sqlite  0  2000  0755 0644
  set_perm $MODPATH/sqlite  0  2000  0755 0644
  

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code

# ================================================================================================
#!/system/bin/sh

# Check if device is boot in TWRP/classic mode
TWRP=$(ps | grep twrp)

if [ -n "$TWRP" ]; then
	BOOT_TWRP=1
else
	BOOT_TWRP=0
fi

# Initial setup
if [ BOOT_TWRP == 1 ]; then
	PATH=$PATH:/system/xbin/:/data/adb/magisk/
fi
magisk=$(ls /data/adb/magisk/magisk || ls /sbin/magisk) 2>/dev/null;
export mag_busybox=/data/adb/magisk/busybox
export grep=$($mag_busybox grep > /dev/null 2>&1)
export wget=$($mag_busybox wget > /dev/null 2>&1)
export awk=$($mag_busybox awk > /dev/null 2>&1)
MAGISK_VERSION=$(/data/adb/magisk/magisk -c | /data/adb/magisk/busybox grep -Eo '[1-9]{2}\.[0-9]+')
case "$MAGISK_VER" in
'15.'[1-9]*) # Version 15.1 - 15.9
    BBOX_PATH=/sbin/.core/img/busybox-ndk
;;
'16.'[1-9]*) # Version 16.1 - 16.9
    BBOX_PATH=/sbin/.core/img/busybox-ndk
;;
'17.'[1-3]*) # Version 17.1 - 17.3
    BBOX_PATH=/sbin/.core/img/busybox-ndk
;;
'17.'[4-9]*) # Version 17.4 - 17.9
    BBOX_PATH=/sbin/.magisk/img/busybox-ndk
;;
'18.'[0-9]*) # Version 18.x
    BBOX_PATH=/sbin/.magisk/img/busybox-ndk
;;
'19.'[0-9a-zA-Z]*) # All versions 19
	BBOX_PATH=/data/adb/modules/busybox-ndk
;;
*)
    ui_print "Unknown version: $1"
;;
esac



Detach_version=$($mag_busybox grep 'version=.*' "$TMPDIR/module.prop" | sed 's/version=//')
ui_print " "
ui_print "  === Detach $Detach_version ===  "
ui_print " "
ui_print "- Checking pre-requests"
ui_print " "
sleep 2;

if [[ -e "$BBOX_PATH/disable" || -e "$BBOX_PATH/SKIP_MOUNT" || -e "$BBOX_PATH/update" ]]; then
	echo -e "!- Make sure you have the 'Busybox for Android-NDK' installed,\nenabled and up-to-date in your Magisk Manager.\nIt's a pre-request for the module."
fi

sleep 1;
ui_print "- Pre-request checks done"
ui_print " "

sleep 2;
ui_print "- Prepare stuff"
ui_print " "

unzip -o "$ZIPFILE" sqlite -d $TMPDIR

SERVICESH=$MODPATH/service.sh
if [ -e "$SERVICESH" ]; then
	CTSERVICESH=$(awk 'END{print NR}' $SERVICESH)
	if [ "$CTSERVICESH" -gt "30" ]; then
		ui_print "Cleanup file.."
		sed -i -e '30,$d' "$SERVICESH"
	fi
fi
	

sleep 1;
ui_print "- Prepare done"
sleep 2;
ui_print " "

	
	# ================================================================================================

CONF=$(ls /sdcard/detach.txt || ls /sdcard/Detach.txt || ls /sdcard/DETACH.txt || ls /storage/emulated/0/detach.txt || ls /storage/emulated/0/Detach.txt || ls /storage/emulated/0/DETACH.txt) 2>/dev/null;
CHECK=$(cat "$CONF" | tail -n +5 | grep -v -e "#.*") 2>/dev/null;
	
if [ -n "$CONF" ] && [ ! -z "$CHECK" ]; then
	DETACH=$TMPDIR/tmp_DETACH
	MAGSH=$TMPDIR/service.sh
		
	[ -e "$DETACH" ] || touch "$DETACH" && chmod 0664 "$DETACH"
	
	ui_print "=> "${CONF}" file found"
	sleep 2;
	ui_print " "
	ui_print "=> Following basic apps will be hidden:"
	sleep 1;
	
	if grep -qo '^Gmail' $CONF; then
		ui_print "Gmail"
		echo "  # Gmail" >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.gm\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Google App' $CONF; then
		ui_print "Google App"
		echo '  # Google App' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.googlequicksearchbox\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Google Plus' $CONF; then
		ui_print "Google Plus"
		echo '  # Google Plus' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.plus\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Hangouts' $CONF; then
		ui_print "Hangouts"
		echo '  # Hangouts' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.talk\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^YouTube' $CONF; then
		ui_print "YouTube"
		echo '  # YouTube' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.youtube\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Gboard' $CONF; then
		ui_print "Gboard"
		echo '  # Gboard' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.inputmethod.latin\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Contacts' $CONF; then
		ui_print "Contacts"
		echo '  # Contacts' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.contacts\''";' >> $DETACH
		echo '' >> $DETACH
		fi
	if grep -qo '^Phone' $CONF; then
		ui_print "Phone"
		echo '  # Phone' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.dialer\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Photos' $CONF; then
		ui_print "Photos"
		echo '  # Photos' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.photos\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Clock' $CONF; then
		ui_print "Clock"
		echo '  # Clock' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.deskclock\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Camera' $CONF; then
		ui_print "Camera"
		echo '  # Camera' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.GoogleCamera\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Inbox' $CONF; then
		ui_print "Inbox"
		echo '  # Inbox' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.inbox\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Duo' $CONF; then
		ui_print "Duo"
		echo '  # Duo' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.tachyon\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Dropbox' $CONF; then
		ui_print "Dropbox"
		echo '  # Dropbox' >> $DETACH
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.dropbox.android\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^PushBullet' $CONF; then
		ui_print "PushBullet"
		echo '  # PushBullet' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.pushbullet.android\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Calendar' $CONF; then
		ui_print "Calendar"
		echo '  # Calendar' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.calendar\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Keep' $CONF; then
		ui_print "Keep"
		echo '  # Keep' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.keep\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Telegram' $CONF; then
		ui_print "Telegram"
		echo '  # Telegram' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'org.telegram.messenger\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Swiftkey' $CONF; then
		ui_print "Swiftkey"
		echo '  # Swiftkey' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.touchtype.swiftkey\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Translate' $CONF; then
		ui_print "Translate"
		echo '  # Translate' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.translate\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Facebook' $CONF; then
		ui_print "Facebook"
		echo '  # Facebook' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.facebook.katana\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Pandora' $CONF; then
		ui_print "Pandora"
		echo '  # Pandora' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.pandora.android\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Twitter' $CONF; then
		ui_print "Twitter"
		echo '  # Twitter' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.twitter.android\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Slack' $CONF; then
		ui_print "Slack"
		echo '  # Slack' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.Slack\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Mega' $CONF; then
		ui_print "Mega"
		echo '  ' >> $DETACH 
		echo '  # Mega' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'mega.privacy.android.app\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^WhatsApp' $CONF; then
		ui_print "WhatsApp"
		echo '  # WhatsApp' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.whatsapp\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Voice' $CONF; then
		ui_print "Voice"
		echo '  # Voice' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.googlevoice\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Drive' $CONF; then
		ui_print "Drive"
		echo '  # Drive' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.docs\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Netflix' $CONF; then
		ui_print "Netflix"
		echo '  # Netflix' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.netflix.mediaclient\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Pixel Launcher' $CONF; then
		ui_print "Pixel Launcher"
		echo '  # Pixel Launcher' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.nexuslauncher\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Wallpapers' $CONF; then
		ui_print "Wallpapers"
		echo '  # Wallpapers' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.wallpaper\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Capture' $CONF; then
		ui_print "Capture"
		echo '  # Capture' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.gopro.smarty\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Google Connectivity Services' $CONF; then
		ui_print "Google Connectivity Services"
		echo '  # Google Connectivity Services' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.gcs\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Google VR Services' $CONF; then
		ui_print "Google VR Services"
		echo '  # Google VR Services' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.vr.vrcore\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Google Play Services' $CONF; then
		ui_print "Google Play Services"
		echo '  # Google Play Services' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.gms\''";' >> $DETACH
		echo '' >> $DETACH
	fi
	if grep -qo '^Google Carrier Services' $CONF; then 
		ui_print "Google Carrier Services"
		echo '  # Google Carrier Services' >> $DETACH 
		echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.ims\''";' >> $DETACH
	fi
	cat "$DETACH" >> "$MAGSH"
	echo " " >> "$MAGSH"
	# rm -f $DETACH
	ui_print " "
	sleep 2;
	ui_print "=> The hidden of basic applications is done.";sleep 2;
	ui_print " "
else
	sleep 1;
	ui_print "=> No Detach.txt file found so no basic app added"
	ui_print "or"
	ui_print "=> No one uncommented app in your file"
	ui_print " "
	break
fi

# ================================================================================================

PACKAGES=$(ls /sdcard/detach.custom || ls /sdcard/detach.custom.txt || ls /sdcard/DETACH.CUSTOM || ls /sdcard/DETACH.CUSTOM.TXT || ls /sdcard/Detach.custom.txt || ls /sdcard/Detach.Custom.txt) 2>/dev/null;
BAK=$TMPDIR/detach.custom.bak
FINALCUST=$TMPDIR/detach.custom.final
MAGSH=$TMPDIR/service.sh
SQSH=$TMPDIR/sqlite.txt
SQSHBAK=$TMPDIR/sqlite.bak

if [ -e "$PACKAGES" ]; then
	ui_print " "
	ui_print "=> "${PACKAGES}" file found"
	sleep 2;
	ui_print " "
	ui_print "=> Custom packages file checks..."
	sleep 1;
		
	# Check if 1rst line of the file is writed or not
	cust_line=$(sed -n '1p' "$PACKAGES")
	cust_line_check=$(echo "$cust_line" | grep '[a-zA-Z]')
	if [ -n "$cust_line_check" ]; then CH_cust_line=0; else CH_cust_line=1; fi
	# ------------------------------------------------------------------------------------
	
	# Check if file is writed with LF or CR LF
	LF_INIT=$(awk -v RS='\r\n' '{ print}' "$PACKAGES" | wc -l)
	LF_TEST=$(cat -e "$PACKAGES" | wc -l)
	LF_FINAL=$((LF_TEST+1))
	if [ "$LF_INIT" != "$LF_FINAL" ]; then CH_LF=1; else CH_LF=0; fi
	
	# Check for if multiple blancks lines at END of the file
	LS_SUPP=$(cat -e "$PACKAGES" | grep '$' | grep -v '[:A-Za-z:]' | wc -l)
	if [ "$LS_SUPP" -eq "0" ]; then CH_LF=0; else CH_LF=1; fi
	# ------------------------------------------------------------------------------------
	
	# Check if one of custom packages names exist in the detach.txt file (to avoid duplicates)
	if [ -n "$CONF" ] && [ ! -z "$CHECK" ] 2>/dev/null; then
		cat "$PACKAGES" | sed -r 's| |_|g' > "$TMPDIR/PACKAGES.txt"
		cat "$CONF" | tail -n +5 | sed 's/#//' > "$TMPDIR/Detach.txt"
		SAME_CHECK=$(sort "$TMPDIR/PACKAGES.txt" "$TMPDIR/Detach.txt" | awk 'dup[$0]++ == 1')
		if [ -n "$SAME_CHECK" ]; then CH_DUPL=1; else CH_DUPL=0; fi
	fi
	# ------------------------------------------------------------------------------------
	
	# Check if custom packages names exist on Play Store (if WIFI and/or LTE are available
	if [ BOOT_TWRP == 1 ]; then
		CONNEXION_PING=$(time ping -w3 8.8.8.8)
		CONNEXION_CHECK=$(echo 'unknow host')
		if grep -qs "$CONNEXION_CHECK" "$CONNEXION_PING"; then
			CH_ONLINE=0
		else
			touch "$TMPDIR/DL_check.txt"
			ONLINE=$(awk '{ print }' "$PACKAGES")
			printf '%s\n' "$ONLINE" | while IFS= read -r line
				do echo "$line | " >> "$TMPDIR/DL_check.txt" && wget --no-check-certificate -q -O "$TMPDIR/$line.html" "https://play.google.com/store/apps/details?id=$line&hl=en" 	>> "$TMPDIR/DL_check.txt" 2>&1 >> "$TMPDIR/DL_check.txt" && echo -e "\n\n" >> "$TMPDIR/DL_check.txt"
				sed -i -e ':a;N;$!ba;s/ | \n/ /g' "$TMPDIR/DL_check.txt"
			done
			cat "$TMPDIR/DL_check.txt" | grep '404' | awk '{ print $1 }' > "$TMPDIR/DL_final_check.txt"
			if [ -s "$TMPDIR/DL_final_check.txt" ]; then
				CH_ONLINE=1
			else
				CH_ONLINE=0
			fi
		fi
	else
		CH_ONLINE=0
	fi
	
	# ------------------------------------------------------------------------------------
		
	if [ "$CH_cust_line" = "1" ] || [ "$CH_LF" = "1" ] || [ "$CH_DUPL" = "1" ] || [ "$CH_ONLINE" = "1" ]; then
		if [ "$CH_cust_line" = "1" ]; then
			ui_print
			ui_print "!- Your \""$PACKAGES"\" file is empty!"
			ui_print "! => So we're going to forget it just for this time."
			ui_print
		fi
		if [ "$CH_LF" = "1" ]; then
			ui_print
			ui_print "!- Your \""$PACKAGES"\" file wasn't created under Android or Linux devices."
			ui_print "!- Or it can be malformated, please note that only 'LF' newlines types are allowed."
			ui_print "!- You must left a blanck line at the end of your file also."
			ui_print "! => So we're going to forget it just for this time."
			ui_print
		fi
		if [ "$CH_DUPL" = "1" ]; then
			ui_print
			ui_print "!- Your \""$PACKAGES"\" file have following duplicate(s):"
			echo "${SAME_CHECK}"
			ui_print "! => So we're going to forget it just for this time."
			ui_print
		fi
		if [ "$CH_ONLINE" = "1" ]; then
			ui_print
			echo -e "\n!- One or more packages names from your \""$PACKAGES"\" file\n!- don't exist on the Play Store:"
			cat "$TMPDIR/DL_final_check.txt"
			ui_print "! => So we're going to forget it just for this time."
			ui_print
		fi
		break
	else
		ui_print " "
		ui_print "=> ""$PACKAGES"" file checks done."
		sleep 2;
		ui_print " "
		ui_print "=> Following custom apps will be hidden:"
		sleep 1;
		ui_print " "
		
		print_custom=$(awk '{ print }' $PACKAGES)
		printf '%s\n' "$print_custom" | while IFS= read -r line
			do ui_print "$line"
		done
		
		
		test -f "$BAK" || touch "$BAK"
		test -f "$FINALCUST" || touch "$FINALCUST"
	
		cp -f "$PACKAGES" "$BAK"
		chmod 0644 "$BAK"
	
		echo "# Custom Packages" >> "$FINALCUST"
	
		cp "$SQSH" "$SQSHBAK"
		chmod 0644 "$SQSHBAK"
		SQLITE_CMD=$(awk '{ print }' $SQSHBAK)
	
		for i in $(cat $BAK); do echo -e "	./sqlite \$PLAY_DB_DIR/library.db \"UPDATE ownership SET library_id = 'u-wl' where doc_id = '$i'\";" >> $FINALCUST; done
				
		cat "$FINALCUST" >> "$MAGSH"
		
		ui_print " "
		ui_print "- Custom apps has been added successfully"
		sleep 1;
		ui_print " "
	fi
else
	ui_print " "
	ui_print "=> No custom app added"
	sleep 2;
	ui_print " "
	break
fi

ui_print "- Module setup done"
ui_print " "
ui_print " "


ui_print "=========================="
ui_print " "
ui_print "Detach work in progress"
ui_print "..."; sleep 1;
ui_print " "


chmod +x $TMPDIR/sqlite
instant_run=$TMPDIR/instant_run.sh
instant_run_two=$TMPDIR/instant_run_two.sh
test -e "$instant_run" || touch "$instant_run"
chmod 0777 "$instant_run" && chmod +x "$instant_run"
PS_DATA_PATH=/data/data/com.android.vending/databases/library.db
	
# Multiple Play Store accounts compatibility
ps_accounts=$("$TMPDIR/sqlite" $PS_DATA_PATH "SELECT account FROM ownership" | sort -u | wc -l)
	
cat /dev/null > "$instant_run"

echo -e "PLAY_DB_DIR=/data/data/com.android.vending/databases\nSQLITE=${TMPDIR}\n\n\nam force-stop com.android.vending\n\ncd \$SQLITE\n\n" >> "$instant_run"
sed -n -e '31,$p' "$MAGSH" | grep sqlite  >> "$instant_run"
	
echo -e "\n" >> "$instant_run"
	
test -e "$TMPDIR/first_detach_result.txt" || touch "$TMPDIR/first_detach_result.txt"
chmod 0777 "$TMPDIR/first_detach_result.txt"
sh "$instant_run"
	
if [ "$ps_accounts" -gt "1" ]; then
	test -e "$instant_run_two" || touch "$instant_run_two"
	chmod 0777 "$instant_run_two" && chmod +x "$instant_run_two"
	echo -e "PLAY_DB_DIR=/data/data/com.android.vending/databases\nSQLITE=${MAGIMG}/Detach\n\n\nam force-stop com.android.vending\n\ncd \$SQLITE\n\n" > "$instant_run_two"
	am force-stop com.android.vending
	for i in {1..${ps_accounts_final}}; do grep sqlite "$instant_run" > "$instant_run_two"; done
	sed -i -e 's/.\t\/sqlite/.\/sqlite/' "$instant_run_two"
	sed -i -e 's/..\/sqlite/.\/sqlite/' "$instant_run_two"
	sed -i -e "s/SQLITE=\$MODD.\/sqlite//" "$instant_run_two"
	echo -e '\n' >> "$instant_run_two"
		
	sh "$instant_run_two"
fi
	
		
wrong_result=$(echo "Error: UNIQUE constraint failed: ownership.account,")
if grep -q "$wrong_result" "$TMPDIR/first_detach_result.txt"; then
	ui_print " "
	ui_print "Database file corrupted"
	ui_print "Database file need to be fixed, so please wait some little seconds..."; sleep 2
	ui_print " "
		
	ACTAPPS=$TMPDIR/actapps.txt
	ACTAPPSBCK=$TMPDIR/actapps.bak
	FINAL=$TMPDIR/final.sh
	
	for o in "$ACTAPPS" "$ACTAPPSBCK" "$FINAL"; do touch "$o" && cat /dev/null > "$o" && chmod 0644 "$o"; done
	
	PLAY_DB_DIR=/data/data/com.android.vending/databases
	
	grep sqlite "$MAGSH" > "$ACTAPPS"
	sed -i -e "s/.\/sqlite \$PLAY_DB_DIR\/library.db \"UPDATE ownership SET library_id = 'u-wl' where doc_id = '//" -i -e "s/'\";//" "$ACTAPPS"
	sed -i -e '1d' "$ACTAPPS"
	sed -i -e 's/[[:blank:]]*//' "$ACTAPPS"
	
	
	cp -f "$ACTAPPS" "$ACTAPPSBCK"
	
	var_ACTAPPS=$(awk '{ print }' "$ACTAPPSBCK")
	
	am force-stop com.android.vending
	
	FIRST_PCK_NAME=$(head -n 1 "$ACTAPPS")
	PRESENT_DIR=$(pwd)
	SQL_ENTRY_TEST=$(cd $TMPDIR && ./sqlite $PS_DATA_PATH "SELECT * FROM ownership WHERE doc_id = '${FIRST_PCK_NAME}' AND library_id='3'" | wc -l)
	cd "$PRESENT_DIR"
	ZERO=0
	
	chmod +x "$FINAL"
	
	if [ "$SQL_ENTRY_TEST" -eq 1 ]; then
		echo -e "\ncd $TMPDIR\n\n" >> "$FINAL"
		printf '%s\n' "$var_ACTAPPS" | while IFS= read -r line
			do echo -e "./sqlite $PLAY_DB_DIR/library.db \"DELETE FROM ownership WHERE doc_id = '$line' AND library_id = '3'\";\n" >> "$FINAL"
		done
		cd "$TMPDIR"
		chmod +x "$FINAL"
		sh "$FINAL"
		cd "$PRESENT_DIR"
	else
		echo -e "\ncd $TMPDIR\n\n" >> "$FINAL"
		while [ "$ZERO" -le "$SQL_ENTRY_TEST" ]; do
			printf '%s\n' "$var_ACTAPPS" | while IFS= read -r line
				do echo -e "./sqlite $PLAY_DB_DIR/library.db \"DELETE FROM ownership WHERE doc_id = '$line' AND library_id = '3'\";\n" >> "$FINAL"
			done
			SQL_ENTRY_TEST=$(($SQL_ENTRY_TEST - 1))
		done
		cd "$TMPDIR"
		chmod +x "$FINAL"
		sh "$FINAL"
		cd "$PRESENT_DIR"
	fi
	
	for f in "$ACTAPPS" "$ACTAPPSBCK"; do rm -f "$f"; done
	ui_print "Database file fixed."
	else		
	ui_print "Detach done"
	ui_print " "
	ui_print "=========================="
	ui_print " "
	ui_print " "
	sleep 2;
fi

for w in "$FINALCUST" "$SQSHBAK" "$SQSH" "$BAK" "$instant_run"; do rm -f "$w"; done 2>/dev/null

	# ================================================================================================

cp -af $TMPDIR/sqlite $MODPATH/sqlite

ui_print "Finish the script file..";sleep 2;
ui_print " "


echo "" >> "$MAGSH"
echo "# Exit" >> "$MAGSH"
echo "	exit; fi" >> "$MAGSH"
echo "done &)" >> "$MAGSH"

ui_print "- Boot script file is now finished."
ui_print " "
ui_print "=> Just reboot now (:"
sleep 2;
ui_print " "
	
	# ================================================================================================
