#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start mode
# More info in the main Magisk thread

# Detach Apps from Market by hinxnz

# Playstore database and SQLite directory'
PLAY_DB_DIR=/data/data/com.android.vending/databases
SQLITE=$MODDIR

# Wait till boot has completed'
(while [ 1 ]; do
	if [ `getprop sys.boot_completed` = 1 ]; then sleep 60
			
# Disable service that populates database
		pm disable com.android.vending/com.google.android.finsky.dailyhygiene.DailyHygiene'$'DailyHygieneService
		pm disable com.android.vending/com.google.android.finsky.hygiene.DailyHygiene'$'DailyHygieneService
	
# Stop playstore to make changes
		am force-stop com.android.vending

# Change directory'
		cd $SQLITE

# Detach following apps from market
