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
POSTFSDATA=true

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
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/system/bin/Detach 0 0 0777
  set_perm  $MODPATH/sqlite  0  2000  0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code

# ================================================================================================
#!/system/bin/sh
if [ "$MAGISK_VER_CODE" -ge "19000" ]; then
	SERVICESH=$MODPATH/service.sh
	
	ui_print    
	ui_print "- Prepare stuff"
	ui_print   
	
	if [ -e "$SERVICESH" ]; then
		CTSERVICESH=$(awk 'END{print NR}' $SERVICESH)

		if [ "$CTSERVICESH" -gt "30" ]; then
			ui_print Cleanup file..
			sed -i -e '30,$d' "$SERVICESH"
		fi
	fi

	ui_print "- Prepare done"
	ui_print

	
	# ================================================================================================
	
	CONF=$(ls /sdcard/detach.txt || ls /sdcard/Detach.txt || ls /sdcard/DETACH.txt) 2>/dev/null;

	if [ -e "$CONF" ] &&  [ ! -z $(cat "$CONF" | tail -n +5 | grep -v -e "#.*") ]; then

		DETACH=$TMPDIR/tmp_DETACH
		MAGSH=$TMPDIR/service.sh

		test -f $DETACH || touch $DETACH
		chmod 0660 $DETACH
	
		echo "=> "${CONF}" file found"
		sleep 2;
		ui_print "=> Following basic apps will be hidden:"
	
		if grep -o '^Gmail' $CONF; then
			echo "  # Gmail" >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.gm\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Google App' $CONF; then
			echo '  # Google App' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.googlequicksearchbox\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Google Plus' $CONF; then
			echo '  # Google Plus' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.plus\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Hangouts' $CONF; then
			echo '  # Hangouts' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.talk\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^YouTube' $CONF; then
			echo '  # YouTube' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.youtube\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Gboard' $CONF; then
			echo '  # Gboard' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.inputmethod.latin\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Contacts' $CONF; then
			echo '  # Contacts' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.contacts\''";' >> $DETACH
			echo '' >> $DETACH
			fi
		if grep -o '^Phone' $CONF; then
			echo '  # Phone' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.dialer\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Photos' $CONF; then
			echo '  # Photos' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.photos\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Clock' $CONF; then
			echo '  # Clock' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.deskclock\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Camera' $CONF; then
			echo '  # Camera' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.GoogleCamera\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Inbox' $CONF; then
			echo '  # Inbox' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.inbox\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Duo' $CONF; then
			echo '  # Duo' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.tachyon\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Dropbox' $CONF; then
			echo '  # Dropbox' >> $DETACH
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.dropbox.android\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^PushBullet' $CONF; then
			echo '  # PushBullet' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.pushbullet.android\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Calendar' $CONF; then
			echo '  # Calendar' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.calendar\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Keep' $CONF; then
			echo '  # Keep' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.keep\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Telegram' $CONF; then
			echo '  # Telegram' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'org.telegram.messenger\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Swiftkey' $CONF; then
			echo '  # Swiftkey' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.touchtype.swiftkey\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Translate' $CONF; then
			echo '  # Translate' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.translate\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Facebook' $CONF; then
			echo '  # Facebook' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.facebook.katana\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Pandora' $CONF; then
			echo '  # Pandora' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.pandora.android\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Twitter' $CONF; then
			echo '  # Twitter' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.twitter.android\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Slack' $CONF; then
			echo '  # Slack' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.Slack\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Mega' $CONF; then
			echo '  ' >> $DETACH 
			echo '  # Mega' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'mega.privacy.android.app\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^WhatsApp' $CONF; then
			echo '  # WhatsApp' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.whatsapp\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Voice' $CONF; then
			echo '  # Voice' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.googlevoice\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Drive' $CONF; then
			echo '  # Drive' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.docs\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Netflex' $CONF; then
			echo '  # Netflex' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.netflix.mediaclient\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Pixel Launcher' $CONF; then
			echo '  # Pixel Launcher' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.nexuslauncher\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Wallpapers' $CONF; then
			echo '  # Wallpapers' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.wallpaper\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Capture' $CONF; then
			echo '  # Capture' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.gopro.smarty\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Google Connectivity Services' $CONF; then
			echo '  # Google Connectivity Services' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.gcs\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Google VR Services' $CONF; then
			echo '  # Google VR Services' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.vr.vrcore\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Google Play Services' $CONF; then
			echo '  # Google Play Services' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.gms\''";' >> $DETACH
			echo '' >> $DETACH
		fi
		if grep -o '^Google Carrier Services' $CONF; then 
			echo '  # Google Carrier Services' >> $DETACH 
			echo '  	./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.ims\''";' >> $DETACH
		fi
		cat $DETACH >> $MAGSH
		echo " " >> $MAGSH
		rm -f $DETACH
		ui_print
		ui_print
	else
		ui_print "=> No basic app added"
		ui_print
		ui_print
		ui_print
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
		
		ui_print "=> "${PACKAGES}" file found"
		sleep 2;
		
		cust_line=$(sed -n '1p' $PACKAGES)
		
		if [[ -z "$cust_line" ]]; then
			ui_print "WOW WOW WOW BE CAREFUL!"
			ui_print "Your \""$PACKAGES"\" file is empty!"
			ui_print "=> So we\'re going to forget it just for this time."
			ui_print
			ui_print
			break
		else
			ui_print "=> Following custom apps will be hidden:"
			ui_print
			cat "$PACKAGES"
			ui_print ""$PACKPACK""
		
			test -f $BAK || touch $BAK
			test -f $FINALCUST || touch $FINALCUST
		
			cp -f $PACKAGES $BAK
			chmod 0644 $BAK
		
			echo "# Custom Packages" >> $FINALCUST
		
			cp $SQSH $SQSHBAK
			chmod 0644 $SQSHBAK
			SQLITE_CMD=$(awk '{ print }' $SQSHBAK)
		
			for i in $(cat $BAK); do echo -e "	./sqlite \$PLAY_DB_DIR/library.db \"UPDATE ownership SET library_id = 'u-wl' where doc_id = '$i'\";" >> $FINALCUST; done
		
			cat $FINALCUST >> $MAGSH
		
			ui_print "- Custom apps has been added successfully"
			ui_print
			ui_print
			ui_print
		fi
	else
		ui_print "=> No custom app added"
		sleep 2;
		ui_print
		ui_print
		break
	fi

	rm -f "$FINALCUST" 2>/dev/null
	rm -f "$SQSHBAK" 2>/dev/null
	rm -f "$SQSH" 2>/dev/null
	rm -f "$BAK" 2>/dev/null
	

	# ================================================================================================
	
	ui_print "Finish the script file.."
	sleep 2;
	ui_print
	ui_print
	echo "" >> $MAGSH
	echo "# Exit" >> $MAGSH 
	echo "	exit; fi" >> $MAGSH 
	echo "done &)" >> $MAGSH 

	ui_print "Boot script file is now finished."
	ui_print "=> Just reboot now"
	sleep 2;
	ui_print
	ui_print
	ui_print

	# ================================================================================================
fi

	
