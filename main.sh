#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk change its mount point in the future
MODDIR=${0%/*}
# This script will be executed in late_start service mode. More info in the main Magisk thread
# Detach Apps from Market by hinxnz
# Playstore database and SQLite directory'
PLAY_DB_DIR=/data/data/com.android.vending/databases
MAGMOD=$MODDIR
SQLITE=$MAGMOD
SERVICESH=$MODDIR/main.sh
# Wait till boot has completed'

i=0
# Wait till boot has completed'
(while [ 1 ]; do

	((i++))
	if [[ $i -gt 1 ]]; then break; fi
#set boot status = ture


# Disable service that populates database
# (in investigation..)	
# Stop playstore to make changes
	am force-stop com.android.vending
	sleep 1
# Change directory'
	cd $MAGMOD
# Detach following apps from market
