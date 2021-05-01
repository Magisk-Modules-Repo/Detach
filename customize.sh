# ================================================================================================
#!/system/bin/sh
SKIPUNZIP=1

# =============================================
# Work beginning
twrp() {
# Check if device is boot in TWRP/classic mode
touch "$TMPDIR/twrp_check.txt"
pstree | grep 'recovery' >> "$TMPDIR/twrp_check.txt"

if grep -q 'recovery' "$TMPDIR/twrp_check.txt"; then
	BOOT_TWRP="1"
fi
}


pre_request() {
# =============================================
# Unzip everything
ui_print
ui_print "- Extracting module files"
[ ! -d "$MODPATH/system/bin" ] && mkdir -p "$MODPATH/system/bin"

#Store sqlite based on CPU Arc.	
	case $ARCH in
		arm|ARM|Arm)
				
			sqlite3=sqlite_arm
		;;
		arm64|ARM64|Arm64)
		
			sqlite3=sqlite_arm64
		;;
		x86|X86)
		
		sqlite3=sqlite_x86
		;;
		x64|X64)
			sqlite3=sqlite_x64
		;;
	esac
			
unzip -o "$ZIPFILE" module.prop service.sh main.sh appslist.csv sepolicy.rule compatibility.txt "$sqlite3" sqlite.txt 'system/*' -x LICENSE .gitattributes README.md -d "$TMPDIR" 1>/dev/null

[ ! -e "$TMPDIR/system/bin/Detach" ] && unzip -o "$ZIPFILE" 'system/system/bin/Detach' "$TMPDIR/system/bin/Detach"

#Rename sqlite_* to default name
mv -f "$TMPDIR/$sqlite3" "$TMPDIR/sqlite" 

#now copy it to it's location
cp -af "$TMPDIR/system/bin/Detach" "$MODPATH/system/bin/Detach"
#Write MODDIR=data/adb/modules/Detach
baseDir=$(echo $MODPATH | sed s/"_update"//)
sed  -i -e 's~^MODDIR.*$~MODDIR='"${baseDir}"'~g' "$MODPATH/system/bin/Detach"

rm -f "$TMPDIR/LICENCE" && rm -f "$MODPATH/LICENCE"
rm -f "$TMPDIR/Detach.txt" && rm -f "$MODPATH/Detach.txt"
rm -f "$TMPDIR/.gitattributes" && rm -f "$MODPATH/.gitattributes"

[ ! -e "$TMPDIR/sqlite" ] && abort 'sqlite no exist!'
set_perm_recursive $TMPDIR 0 0 0755 0644
chmod 0755 $TMPDIR/sqlite
chgrp 2000 $TMPDIR/sqlite


# =============================================
# Symbolic link for lowercase/UPPERCASE support in terminal
[ -d "$MODPATH/system/bin/" ] || mkdir -p "$MODPATH/system/bin/"
ln -sf Detach "$MODPATH/system/bin/detach"
  

Detach_version=$(grep 'version=.*' "$TMPDIR/module.prop" | sed 's/version=//')
ui_print " "
ui_print "- Detach $Detach_version"
ui_print "- By Rom @ xda-developers"
ui_print " "
ui_print "- Checking pre-requests"
sleep 1;

if [[ -e "$BBOX_PATH/disable" || -e "$BBOX_PATH/SKIP_MOUNT" || -e "$BBOX_PATH/update" ]]; then

	ui_print "!- Make sure you have the 'Busybox for Android-NDK' installed on your device,"
	ui_print "!- enabled and up-to-date in your Magisk Manager."
	ui_print "!- It's a pre-request for the module."
fi


sleep 1;
ui_print "- Pre-request checks done"

sleep 1;
ui_print "- Prepare stuff"


SERVICESH=$TMPDIR/main.sh
CONF=$(ls /sdcard/Detach.txt || ls /sdcard/detach.txt || ls /sdcard/DETACH.txt || ls /storage/emulated/0/detach.txt || ls /storage/emulated/0/Detach.txt || ls /storage/emulated/0/DETACH.txt) 2>/dev/null;
SQLITE=$TMPDIR

if [ "$CONF" != "/sdcard/Detach.txt" -o "$CONF" != "/storage/emulated/0/Detach.txt" ]; then
mv -f "$CONF" /sdcard/Detach.txt
fi

# Check for bad syntax in the Detach.txt file due to wrong config in some BETAs versions
sed -n '5,40p' "$CONF" >> "$TMPDIR/SYN_CONF.txt"

grep -q '\.' "$TMPDIR/SYN_CONF.txt"; if [ $? -eq 0 ]; then
	ui_print ""
	ui_print "!- You "$CONF" file contain error(s), please use the default one to remove the errors and try again."
	ui_print ""
	CONF_BAD=1
fi


UP_SERVICESSH=$MODPATH/main.sh
if [ -e "$UP_SERVICESSH" ] && test ! "$CONF_BAD"; then
	CTSERVICESH=$(awk 'END{print NR}' $UP_SERVICESSH)
	if [ "$CTSERVICESH" -gt "32" ]; then
		ui_print "- Cleanup file.."
		sed -i -e '32,$d' "$SERVICESH"
	fi
fi


sleep 1;
test ! "$CONF_BAD" && ui_print "- Prepare done" || abort '- Wrong module setup'
sleep 1;
}



simple_mode_pre_request() {
ui_print "- Welcome in Simple mode :)"
ui_print ""
		
ui_print "- Checking your Detach.txt file"; sleep 1;
CONF_CHECK1=$(cat "$CONF" | grep 'Detach Market Apps Configuration')
CONF_CHECK2=$(cat "$CONF" | grep 'Remove comment (#) to detach an App.')
CONF_CHECK3=$(wc -l "$CONF" | sed "s| $CONF||")

if [ ! "$CONF_CHECK1" -o ! "$CONF_CHECK2" -o "$CONF_CHECK3" -lt "41" -a "$BOOT_TWRP" = 0 ]; then
	ui_print "!- Make sure you have the original 'Detach.txt' file"; sleep 1;
	ui_print "=> Download the original 'Detach.txt' file"
	am start -a android.intent.action.VIEW -d https://raw.githubusercontent.com/sobuj53/Detach/master/Detach.txt
	abort "!- Module setup canceled"
fi
}



# Check for automatic custom packages names to add
simple_mode_checks() {
ui_print "- Checks beginning"; sleep 1;

# Checks for custom packages names
# Check if line 46 of Detach.txt for custom packages is writed or not
line_no=$(grep -n '# Other applications' $CONF | cut -d: -f 1)
line_no=$((line_no+1))


custom_check=$(tail -n +"$line_no" "$CONF" | grep '[a-zA-Z]')
# ------------------------------------------------------------------------------------

#not required anymore
# Check if there is too much spaces in custom packages from user input
#SPACES=$(sed -n '/^# Other applications/,$p' "$CONF" | sed 's/\# Other applications//' | grep '[a-zA-Z]')

#if [ $(echo "$SPACES" | grep '[:blanck:]\.') ] || [ $(echo "$SPACES" | grep '. ') ] || [ $(echo "$SPACES" | grep '[[:space:]][[:space:]]')]; then
#	sed -i -e 's/ ././' -e 's/. /./' -e 's/ \+//' "$CONF" 2>/dev/null
#fi
# ------------------------------------------------------------------------------------

# Exist in detach.txt or custom packages
# Check if one of custom packages names exist in the detach.txt file (to avoid duplicates)
COMPARE_MAIN=$TMPDIR/COMPARE_MAIN.txt
COMPARE_CUSTOM=$TMPDIR/COMPARE_CUSTOM.txt

#get second last line number
match_line=$(sed '/# Other applications/q' "$CONF")
search=$(echo "$match_line" | awk 'NF { a=b ; b=$0 } END { print a }')
lines_no=$(grep -n "${search}" $CONF | cut -d: -f 1)

lines_no=$((line_no-lines_no-1))


for v in "$COMPARE_MAIN" "$COMPARE_CUSTOM"; do touch "$v" && chmod 0644 "$v"; done

cat "$CONF" | tail -n +"$lines_no" | sed '1,/\# Other applications/!d' | sed 's/# Other applications//' |  grep -v -e "#.*" | grep '[A-Za-z0-9]' > "$COMPARE_MAIN"
sed -n '/# Other applications/,$p' "$CONF" | sed '1d' > "$COMPARE_CUSTOM"

# Check if there is/are duplicate(s) in the Common=Main apps
COMP_WRONG_M=$(awk 'NR==FNR{a[$1]++;next} a[$1] ' "$COMPARE_MAIN" "$COMPARE_CUSTOM")

# If there is an error in the custom apps
COMP_WRONG_C=$(awk 'NR==FNR{a[$1]++;next} a[$1] ' "$COMPARE_CUSTOM" "$COMPARE_MAIN")
if [ "$COMP_WRONG_M" ]; then
	ui_print "- Be carreful! Theses following apps already exist in the common apps list"; sleep 1;
	printf '%s\n' "$COMP_WRONG_C" | while IFS= read -r line
		do ui_print "- $line"
	done
	CH_DUPLICATE=0
fi

if [ "$COMP_WRONG_C" ]; then
	ui_print "- Be carreful! Theses following apps already exist in the custom apps list"; sleep 1;
	printf '%s\n' "$COMP_WRONG_C" | while IFS= read -r line
		do ui_print "- $line"
	done
	CH_DUPLICATE=0
fi
# ------------------------------------------------------------------------------------


ui_print "- Custom apps compatibility checks done."
sleep 1;
}



simple_mode_basic() {	
ui_print "- Following basic apps will be hidden:"
sleep 1;
DETACH=$TMPDIR/basic_apps.txt
echo "" >> "$DETACH"
	
if grep -qo '^Gmail' $CONF; then
	ui_print "- Gmail"
	echo "  # Gmail" >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.gm\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Google App' $CONF; then
	ui_print "- Google App"
	echo '  # Google App' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.googlequicksearchbox\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Google Plus' $CONF; then
	ui_print "- Google Plus"
	echo '  # Google Plus' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.plus\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Hangouts' $CONF; then
	ui_print "- Hangouts"
	echo '  # Hangouts' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.talk\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^YouTube' $CONF; then
	ui_print "- YouTube"
	echo '  # YouTube' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.youtube\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^YouTube Music' $CONF; then
	ui_print "- YouTube Music"
	echo '  # YouTube Music' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.youtube.music\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Gboard' $CONF; then
	ui_print "- Gboard"
	echo '  # Gboard' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.inputmethod.latin\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Contacts' $CONF; then
	ui_print "- Contacts"
	echo '  # Contacts' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.contacts\''";' >> $DETACH
	echo '' >> $DETACH
	fi
if grep -qo '^Phone' $CONF; then
	ui_print "- Phone"
	echo '  # Phone' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.dialer\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Photos' $CONF; then
	ui_print "- Photos"
	echo '  # Photos' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.photos\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Clock' $CONF; then
	ui_print "- Clock"
	echo '  # Clock' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.deskclock\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Camera' $CONF; then
	ui_print "- Camera"
	echo '  # Camera' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.GoogleCamera\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Inbox' $CONF; then
	ui_print "- Inbox"
	echo '  # Inbox' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.inbox\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Duo' $CONF; then
	ui_print "- Duo"
	echo '  # Duo' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.tachyon\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Dropbox' $CONF; then
	ui_print "- Dropbox"
	echo '  # Dropbox' >> $DETACH
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.dropbox.android\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^PushBullet' $CONF; then
	ui_print "- PushBullet"
	echo '  # PushBullet' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.pushbullet.android\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Calendar' $CONF; then
	ui_print "- Calendar"
	echo '  # Calendar' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.calendar\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Keep' $CONF; then
	ui_print "- Keep"
	echo '  # Keep' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.keep\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Telegram' $CONF; then
	ui_print "- Telegram"
	echo '  # Telegram' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'org.telegram.messenger\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Swiftkey' $CONF; then
	ui_print "- Swiftkey"
	echo '  # Swiftkey' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.touchtype.swiftkey\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Translate' $CONF; then
	ui_print "- Translate"
	echo '  # Translate' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.translate\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Facebook' $CONF; then
	ui_print "- Facebook"
	echo '  # Facebook' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.facebook.katana\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Pandora' $CONF; then
	ui_print "- Pandora"
	echo '  # Pandora' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.pandora.android\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Twitter' $CONF; then
	ui_print "- Twitter"
	echo '  # Twitter' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.twitter.android\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Slack' $CONF; then
	ui_print "- Slack"
	echo '  # Slack' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.Slack\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Mega' $CONF; then
	ui_print "- Mega"
	echo '  ' >> $DETACH 
	echo '  # Mega' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'mega.privacy.android.app\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^WhatsApp' $CONF; then
	ui_print "- WhatsApp"
	echo '  # WhatsApp' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.whatsapp\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Voice' $CONF; then
	ui_print "- Voice"
	echo '  # Voice' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.googlevoice\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Drive' $CONF; then
	ui_print "- Drive"
	echo '  # Drive' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.docs\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Netflix' $CONF; then
	ui_print "- Netflix"
	echo '  # Netflix' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.netflix.mediaclient\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Pixel Launcher' $CONF; then
	ui_print "- Pixel Launcher"
	echo '  # Pixel Launcher' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.nexuslauncher\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Wallpapers' $CONF; then
	ui_print "- Wallpapers"
	echo '  # Wallpapers' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.wallpaper\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Capture' $CONF; then
	ui_print "- Capture"
	echo '  # Capture' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.gopro.smarty\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Google Connectivity Services' $CONF; then
	ui_print "- Google Connectivity Services"
	echo '  # Google Connectivity Services' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.apps.gcs\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Google VR Services' $CONF; then
	ui_print "- Google VR Services"
	echo '  # Google VR Services' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.vr.vrcore\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Google Play Services' $CONF; then
	ui_print "- Google Play Services"
	echo '  # Google Play Services' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.gms\''";' >> $DETACH
	echo '' >> $DETACH
fi
if grep -qo '^Google Carrier Services' $CONF; then 
	ui_print "- Google Carrier Services"
	echo '  # Google Carrier Services' >> $DETACH 
	echo '	$SQLITE/sqlite $PLAY_DB_DIR/library.db "UPDATE ownership SET library_id = '\'u-wl\' where doc_id = \'com.google.android.ims\''";' >> $DETACH
fi
cat "$DETACH" >> "$SERVICESH"

echo " " >> "$SERVICESH"
# rm -f $DETACH
sleep 1;
ui_print "- The hidden of basic applications is done.";sleep 1;
}



nothing_to_add() {
ui_print "- You have not uncommented any basic application"
ui_print "  or"
ui_print "- written any custom application in your /sdcard/Detach.txt file."
ui_print ""
ui_print "- At least uncomment one or write a custom package name..."
ui_print ""
ui_print "- Install exist..."
}



direct_custom_install() {
ui_print ""
ui_print "- Following custom apps will be hidden:"
sleep 1;

FINALCUST=$TMPDIR/FINALCUST.txt
SQSH=$TMPDIR/sqlite.txt
SQSHBAK=$TMPDIR/sqlite.bak

echo -e "# Custom Packages" >> "$FINALCUST"
cp -af "$SQSH" "$SQSHBAK"

echo "$CHECK_PACKAGES" >> "$TMPDIR/CHECK_PACKAGES.txt"

FINAL_PACKS=$(awk '{ print }' "$TMPDIR/CHECK_PACKAGES.txt")

SHOW_PACKS=$(echo "$FINAL_PACKS" | tr -d '\r')
printf '%s\n' "$SHOW_PACKS" | while IFS= read -r line
	do ui_print "- $line"
done

printf '%s\n' "$FINAL_PACKS" | while IFS= read -r line
	do
		echo -e "	\$SQLITE/sqlite \$PLAY_DB_DIR/library.db \"UPDATE ownership SET library_id = 'u-wl' where doc_id = '$line'\";\n" >> "$FINALCUST"
done

cat "$FINALCUST" >> "$SERVICESH"

ui_print "- Custom apps has been added successfully"
sleep 1;
}


simple_mode_no_custom() {
	ui_print "=> No custom app added"
	sleep 2;
}




instant_detach() {
ui_print ""
ui_print "=========================="
ui_print "- Detach work in progress"
ui_print "..."; sleep 1;

instant_run=$TMPDIR/instant_run.sh
instant_run_two=$TMPDIR/instant_run_two.sh
test -e "$instant_run" || touch "$instant_run"
chmod 0777 "$instant_run" && chmod +x "$instant_run"
PS_DATA_PATH=/data/data/com.android.vending/databases/library.db
	
# Multiple Play Store accounts compatibility
ps_accounts=$("$TMPDIR/sqlite" $PS_DATA_PATH "SELECT account FROM ownership" | sort -u | wc -l)
	
cat /dev/null > "$instant_run"

echo -e "PLAY_DB_DIR=/data/data/com.android.vending/databases\nSQLITE=${TMPDIR}\n\n\nam force-stop com.android.vending\n\ncd \$SQLITE\nsleep 1\n" >> "$instant_run"
sed -n '32,$p' "$SERVICESH" | sed -n '/^[[:space:]]*$SQLITE\/sqlite.*/p' "$SERVICESH" >> "$instant_run"
	
echo -e "\n" >> "$instant_run"
	
test -e "$TMPDIR/first_detach_result.txt" || touch "$TMPDIR/first_detach_result.txt"
chmod 0777 "$TMPDIR/first_detach_result.txt"
sh "$instant_run" > "$TMPDIR/first_detach_result.txt" 2>&1
	
if [ "$ps_accounts" -gt "1" ]; then
	test -e "$instant_run_two" || touch "$instant_run_two"
	chmod 0777 "$instant_run_two" && chmod +x "$instant_run_two"
	echo -e "PLAY_DB_DIR=/data/data/com.android.vending/databases\nSQLITE=${TMPDIR}\n\n\nam force-stop com.android.vending\n\ncd \$SQLITE\nsleep 1\n" > "$instant_run_two"
	am force-stop com.android.vending
	for i in {1..${ps_accounts_final}}; do sed -n '/^[[:space:]]*$SQLITE\/sqlite.*/p' "$instant_run" >> "$instant_run_two"; done

	echo -e '\n' >> "$instant_run_two"
	sh "$instant_run_two"
	
fi
	
		
wrong_result=$(echo "Error: UNIQUE constraint failed: ownership.account,")
if grep -q "$wrong_result" "$TMPDIR/first_detach_result.txt"; then
	ui_print " "
	ui_print "Database file corrupted"
	ui_print "Database file need to be fixed, so please wait some little seconds."
	ui_print "..."; sleep 1;
	
	ACTAPPS=$TMPDIR/actapps.txt
	ACTAPPSBCK=$TMPDIR/actapps.bak
	FINAL=$TMPDIR/final.sh
	
	for o in "$ACTAPPS" "$ACTAPPSBCK" "$FINAL"; do touch "$o" && cat /dev/null > "$o" && chmod 0644 "$o"; done
	
	PLAY_DB_DIR=/data/data/com.android.vending/databases
	sed -n '/^[[:space:]]*$SQLITE\/sqlite.*/p' "$SERVICESH" >> "$ACTAPPS"
	#grep sqlite "$SERVICESH" > "$ACTAPPS"
	sed -i -e "s/\$SQLITE\/sqlite \$PLAY_DB_DIR\/library.db \"UPDATE ownership SET library_id = 'u-wl' where doc_id = '//" -i -e "s/'\";//" "$ACTAPPS"
	sed -i -e '1d' "$ACTAPPS"
	sed -i -e 's/[[:blank:]]*//' "$ACTAPPS"
		
	cp -f "$ACTAPPS" "$ACTAPPSBCK"
	
	var_ACTAPPS=$(awk '{ print }' "$ACTAPPSBCK")
	
	am force-stop com.android.vending
	
	FIRST_PCK_NAME=$(head -n 1 "$ACTAPPS")
	PRESENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
	SQL_ENTRY_TEST=$(cd $TMPDIR && $SQLITE/sqlite $PLAY_DB_DIR/library.db "SELECT * FROM ownership WHERE doc_id = '${FIRST_PCK_NAME}' AND library_id='3'" | wc -l)
	cd "$PRESENT_DIR"
	ZERO=0
	chmod +x "$FINAL"
		
	echo -e "PS_DATA_PATH=\/data\/data\/com.android.vending\/databases\/library.db\n\ncd $TMPDIR\n\n" >> "$FINAL"
	
	if [ "$SQL_ENTRY_TEST" -eq 1 ]; then
		printf '%s\n' "$var_ACTAPPS" | while IFS= read -r line
			do echo -e "$TMPDIR/sqlite $PLAY_DB_DIR/library.db \"DELETE FROM ownership WHERE doc_id = '$line' AND library_id = '3'\";\n" >> "$FINAL"
		done
		cd "$TMPDIR"
		chmod +x "$FINAL"
		sh "$FINAL"
		cd "$PRESENT_DIR"
	else
		echo -e "\ncd $TMPDIR\n\n" >> "$FINAL"
		while [ "$ZERO" -le "$SQL_ENTRY_TEST" ]; do
			printf '%s\n' "$var_ACTAPPS" | while IFS= read -r line
				do echo -e "$TMPDIR/sqlite $PLAY_DB_DIR/library.db \"DELETE FROM ownership WHERE doc_id = '$line' AND library_id = '3'\";\n" >> "$FINAL"
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
	ui_print "..."; sleep 1;
fi
		
ui_print "- Detach done"
ui_print "=========================="
ui_print ""
sleep 1;


}
# ================================================================================================

complete_script() {
# =============================================
ui_print "- Extracting module files"
for i in "$TMPDIR/compatibility.txt" "$TMPDIR/sqlite" "$TMPDIR/service.sh" "$TMPDIR/appslist.csv" "$TMPDIR/sepolicy.rule" "$TMPDIR/sqlite.txt" "$TMPDIR/module.prop"; do cp -af "$i" "$MODPATH/"; done


# =============================================
# Necessary special permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $TMPDIR 0 0 0755 0644
set_perm $MODPATH/system/bin/Detach 0 0 0777
chmod 0755 $TMPDIR/sqlite
chgrp 2000 $TMPDIR/sqlite
chmod 0755 "$MODPATH/sepolicy.rule" && chmod +x "$MODPATH/sepolicy.rule"
chmod 0755 "$MODPATH/service.sh" && chmod +x "$MODPATH/service.sh"

chmod 0755 $MODPATH/sqlite
chgrp 2000 $MODPATH/sqlite


ui_print "- Finish the script file..";sleep 1;

cat "$TMPDIR/compatibility.txt" >> "$SERVICESH"

cp -af "$SERVICESH" "$MODPATH/main.sh"
chmod 0755 "$MODPATH/main.sh" && chmod +x "$MODPATH/main.sh"

ui_print "- Boot script file is now finished."
ui_print "- Reboot your device before using the terminal commands."
ui_print "=> Just reboot now (:"
sleep 1;
}



# ================================================================================================
# ================================================================================================
# ================================================================================================
# Detach Module setup
# Rom @ xda-devlopers
twrp
pre_request

test "$CONF_BAD" && exit

SIMPLE=/sdcard/simple_mode.txt

test -e "$SIMPLE" && simple_mode_pre_request
# ----------------------------------
#get # Other applications line number
line_no=$(grep -n '# Other applications' $CONF | cut -d: -f 1)


#how many line before the Other applications line
match_line=$(sed '/# Other applications/q' "$CONF")
search=$(echo "$match_line" | awk 'NF { a=b ; b=$0 } END { print a }')
lines_no=$(grep -n "${search}" $CONF | cut -d: -f 1)
lines_no=$((line_no-lines_no))

# Check for basics and/or customs
CHECK=$(cat "$CONF" | tail -n +"$lines_no" | sed -n '/# Other applications/q;p' | grep -v -e "#.*" | grep '[A-Za-z0-9]')

# Check if basics apps in Detach.txt file are ready or not
test "$CONF_BAD" && abort "!- WARNING: You basic applications list contain '.' symbol, delete them and try again."


CHECK_OTHER=$(sed -n "$line_no"p "$CONF")
RIGHT_OTHER="# Other applications"
if [ "$CHECK_OTHER" != "$RIGHT_OTHER" ]; then
	unset CHECK_OTHER
fi

line_no=$((line_no+1))

CHECK_PACKAGES=$(cat "$CONF" | tail -n +"$line_no" | grep '[0-9A-Za-z]')

# Checks for Detach.txt file
simple_mode_checks

[[ "$CH_DUPLICATE" == "0" ]] && abort



# For common app(s) ONLY
[ "$CHECK" ] && simple_mode_basic
# ----------------------------------



# If NO basic applications and NO custom packages names
[ -e "$SIMPLE" -a ! "$CHECK" -a ! "$CHECK_PACKAGES" ] && nothing_to_add && exit



# Simple mode - if '# Other applications' is write in Detach.txt WITHOUT custom packages names
if [ -e "$SIMPLE" -a "$CHECK_OTHER" -a ! "$CHECK_PACKAGES" ]; then
	ui_print "!- Warning:"
	ui_print "!- You have enable custom packages application"
	ui_print "!- in your /sdcard/Detach.txt file".
	ui_print "!- But you didn't write any custom packages name after that."
	ui_print "!- We are going to ignore it for this time."
fi



# Simple mode - if '# Other applications' is write in Detach.txt WITH custom packages names
[ -e "$SIMPLE" -a "$CHECK_OTHER" -a "$CHECK_PACKAGES" ] && direct_custom_install
# ----------------------------------

# If '# Other applications' is write in Detach.txt with custom packages names
[ ! -e "$SIMPLE" -a "$CHECK_OTHER" -a "$CHECK_PACKAGES" ] && direct_custom_install
# ----------------------------------

# NO '# Other applications' and NO custom packages names write in Detach.txt
[ -z "$CHECK_OTHER" -a -z "$CHECK_PACKAGES" ] && simple_mode_no_custom
# ----------------------------------





# Finishing the setup
# ----------------------------------
if [ "$(grep -voq 'recovery' "$TMPDIR/twrp_check.txt")" != "recovery" ]; then
	instant_detach
fi

complete_script


ui_print "- Module setup done"
ui_print " "
