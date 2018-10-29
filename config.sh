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
POSTFSDATA=false

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

basics_apps() {
DETACH=$MODPATH/tmp_DETACH
MAGSH=$MODPATH/service.sh
CONF=/sdcard/detach.txt
REMOVAL=/sdcard/detach.remove
BAK=/sdcard/detach.bak
PACKAGES=/sdcard/detach.custom

test -f $DETACH || touch $DETACH

sed -i -e '30,$d' $MAGSH 2>&1

if [ -e $CONF ]; then
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
fi

cat $DETACH >> $MAGSH
echo " " >> $MAGSH
rm -f $DETACH
}

custom_apps() {
PACKAGES=/sdcard/detach.custom
BAK=$MODPATH/detach.custom.bak
FINALCUST=$MODPATH/detach.custom.final
CUSTOM=$MODPATH/tmp_service.sh
MAGSH=$MODPATH/service.sh
SQSH=$MODPATH/sqlite.txt
SQSHBAK=$MODPATH/sqlite.bak

if [ -e $PACKAGES ]; then
	
	test -f $BAK || touch $BAK
	test -f $CUSTOM || touch $CUSTOM
	test -f $FINALCUST || touch $FINALCUST
	
	chmod 0644 $BAK
	cp /dev/null $BAK

	cp -af $PACKAGES $BAK

	echo "# Custom Packages" >> $FINALCUST

	cp $SQSH $SQSHBAK
	SQLITE_CMD=$(awk '{ print }' $SQSHBAK)
	
	for i in $(cat $BAK); do echo "		./sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = \'u-wl\' where doc_id = \'$i\'";" >> $FINALCUST; done
	
	cat $MODPATH/detach.custom.final >> $MAGSH
else
	exit
fi

rm -f $SQSH 2>/dev/null
rm -f $BAK 2>/dev/null
rm -f $CUSTOM 2>/dev/null
}

final() {
echo "" >> $MAGSH
echo "# Exit" >> $MAGSH 
echo "	exit; fi" >> $MAGSH 
echo "done &)" >> $MAGSH 
echo "" >> $MAGSH
}
