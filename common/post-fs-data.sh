#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode

if [ "$MAGISK_VER_CODE" -ge "19000" ]; then

instant_run=$MODDIR/instant_run.sh
SERVICESH=$MODDIR/service.sh
iYTBP=$MAGIMG/iYTBP-Vanced-Magisk-Repo
iYTBPBLACK=$MAGIMG/iYTBP-Vanced-black-Magisk-Repo
iYTBPSH=$iYTBP/post-fs-data.sh
iYTBPBLACKSH=$iYTBPBLACK/post-fs-data.sh
SYSAD=/system/addon.d
iYTBSYSADD=$SYSAD/97-ytva.sh
iYTBSYSSYSADD=/system/$SYSAD/97-ytva.sh
BBPATH=$MAGIMG/busybox-ndk
BBVERSION=`grep versionCode= $BBPATH/module.prop | sed 's/versionCode=//'`

if [ \( -e "$iYTBPSH" \) -o \( -e "$iYTBPBLACKSH" \) -o \( -e "$iYTBSYSADD" \) -o \( -e "iYTBSYSSYSADD" \) ]; then
	mv "$iYTBPSH" "$iYTBP/post-fs-data.sh.bak" 2>/dev/null
	mv "$iYTBPBLACKSH" "$iYTBPBLACK/post-fs-data.sh.bak" 2>/dev/null
	rm -f "$iYTBSYSADD" 2>/dev/null
	rm -f "$iYTBSYSSYSADD" 2>/dev/null
fi

crond_service() {
	crond_instant=$MODDIR/$instant_run
	crondroot=$MODDIR/cronjob
	crondfile=$MODDIR/crond_task
	alias crond=$MAGIMG/busybox-ndk/system/*/crond
	
	echo "0 */2 * * * * sh $MAGMOD/instant_run.sh" > "$crondfile"
	touch "$crondroot"
	crond -b -c "$crondfile" > "$crond_instant"
	cron_service_check=`grep crond`
	chmod +x "$crondfile"
}
