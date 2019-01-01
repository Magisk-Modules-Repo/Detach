##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  ui_print "*******************************"
  ui_print "          Detach          "
  ui_print " Modded by Rom for Magisk v17+"
  ui_print "    All credits to hinxnz"
  ui_print "*******************************"
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644
  set_perm $MODPATH/system/bin/Detach 0 0 0777
  set_perm  $MODPATH/sqlite  0  2000  0755 0644
}

##########################################################################################
# DETACH Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need DETACH logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.

intro() {
MAGIMG=/sbin/.magisk/img
MAGMOD=$MAGIMG/Detach
SERVICESH=$MAGMOD/service.sh
iYTBP=$MAGIMG/iYTBP-Vanced-Magisk-Repo
iYTBPBLACK=$MAGIMG/iYTBP-Vanced-black-Magisk-Repo
iYTBPSH=$iYTBP/post-fs-data.sh
iYTBPBLACKSH=$iYTBPBLACK/post-fs-data.sh
SYSAD=/system/addon.d
iYTBSYSADD=$SYSAD/97-ytva.sh
iYTBSYSSYSADD=/system/$SYSAD/97-ytva.sh

echo -e "\n- Prepare stuff\n"

MAGFILE=$(ls /data/adb/magisk.img || ls /cache/magisk.img) 2>/dev/null;
if [ ! -d "$MAGIMG" ]; then
	mkdir -p "$MAGIMG"
	mount -t ext4 -o rw "$MAGFILE" "$MAGIMG"
fi

BBPATH=$MAGIMG/busybox-ndk
BBVERSION=`grep versionCode= $BBPATH/module.prop | sed 's/versionCode=//'`

if [[ -d "$BBPATH" && "$BBVERSION" -ge "12932" && ! -e "$BBPATH/.replace" ]]; then
	break
else
	echo -e '\n\n! Busybox is not installed\n\n\n\nOr maybe you have to:\n\n=> Enable Busybox for Android NDK in your Magisk Manager\n=> Reboot your device\n=> Try again\n\n'; sleep 4;
	exit 1
fi

if [ \( -e "$iYTBPSH" \) -o \( -e "$iYTBPBLACKSH" \) -o \( -e "$iYTBSYSADD" \) -o \( -e "iYTBSYSSYSADD" \) ]; then
	echo -e "\n\n ! Detach feature of iYTBP Vanced for Magisk has been detected in your modules folder.\n\nIt's incompatible with this module, the post-fs-data.sh file is going to be renamed to:\npost-fs-data.sh.bak\n\n\n"
	mv "$iYTBPSH" "$iYTBP/post-fs-data.sh.bak" 2>/dev/null
	mv "$iYTBPBLACKSH" "$iYTBPBLACK/post-fs-data.sh.bak" 2>/dev/null
	rm -f "$iYTBSYSADD" 2>/dev/null
	rm -f "$iYTBSYSSYSADD" 2>/dev/null
fi

CTSERVICESH=$(awk 'END{print NR}' $SERVICESH)

if [ "$CTSERVICESH" -gt "30" ]; then
	echo -e "\nCleanup file..\n"
	sed -i -e '30,$d' "$SERVICESH"
fi

echo -e "- Prepare done\n\n"
}

basics_apps() {
CONF=$(ls /sdcard/detach.txt || ls /sdcard/Detach.txt || ls /sdcard/DETACH.txt) 2>/dev/null;

if [ -e "$CONF" ]; then
DETACH=$MODPATH/tmp_DETACH
MAGSH=$MODPATH/service.sh

test -f $DETACH || touch $DETACH
chmod 0660 $DETACH
	
	echo -e "\n=> ${CONF} file found"; sleep 2;
	echo -e "\n=> Following basic app(s) will be hidden:\n"
	
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
	echo -e "\n\n"
else
	echo -e "\n=> No basic app added\n\n\n"
	break
fi
}

custom_apps() {
PACKAGES=$(ls /sdcard/detach.custom || ls /sdcard/detach.custom.txt || ls /sdcard/DETACH.CUSTOM || ls /sdcard/DETACH.CUSTOM.TXT || ls /sdcard/Detach.custom.txt || ls /sdcard/Detach.Custom.txt) 2>/dev/null;
BAK=$MODPATH/detach.custom.bak
FINALCUST=$MODPATH/detach.custom.final
MAGSH=$MODPATH/service.sh
SQSH=$MODPATH/sqlite.txt
SQSHBAK=$MODPATH/sqlite.bak

if [ -e $PACKAGES ]; then
	
	echo -e "\n=> ${PACKAGES} file found"; sleep 2;
	
	cust_line=$(sed -n '1p' $PACKAGES)
	
	if [[ -z "$cust_line" ]]; then
		echo -e "\n\nWOW WOW WOW BE CAREFUL!\n\nYour \""$PACKAGES"\" file is empty!\n\n=> So we're going to forget it just for this time.\n\n"
		break
	else
		echo -e "\n=> Following custom apps will be hidden:\n"
		cat "$PACKAGES"
	
		test -f $BAK || touch $BAK
		test -f $FINALCUST || touch $FINALCUST
	
		cp -f $PACKAGES $BAK
		chmod 0644 $BAK
	
		echo "# Custom Packages" >> $FINALCUST
	
		cp $SQSH $SQSHBAK
		chmod 0644 $SQSHBAK
		SQLITE_CMD=$(awk '{ print }' $SQSHBAK)
	
		for i in $(cat $BAK); do echo -e "		./sqlite \$PLAY_DB_DIR/library.db \"UPDATE ownership SET library_id = 'u-wl' where doc_id = '$i'\";" >> $FINALCUST; done
	
		cat $FINALCUST >> $MAGSH
	
		echo -e "\n\n- Custom apps has been added successfully\n\n\n"
	fi
else
	echo -e "\n=> No custom app added\n\n\n"
	break
fi

rm -f $FINALCUST 2>/dev/null
rm -f $SQSHBAK 2>/dev/null
rm -f $SQSH 2>/dev/null
rm -f $BAK 2>/dev/null
}

final() {
echo -e "\nFinish the script file..\n"; sleep 2;
echo "" >> $MAGSH
echo "# Exit" >> $MAGSH 
echo "	exit; fi" >> $MAGSH 
echo "done &)" >> $MAGSH 

echo -e "\nBoot script file is now finished.\n- Just reboot now :)\n\n\n"; sleep 2;
}
