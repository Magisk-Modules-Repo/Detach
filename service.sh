#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk change its mount point in the future
MODDIR=${0%/*}
MAGMOD=/data/adb/modules/Detach
instant_run=$MAGMOD/instant_run.sh
instant_run_two=$MAGMOD/instant_run_two.sh
# This script will be executed in late_start service mode
#Reserved for crond schedule


# More info in the main Magisk thread
# Detach Apps from Market by hinxnz
# Playstore database and SQLite directory'
PLAY_DB_DIR=/data/data/com.android.vending/databases
SQLITE=$MODDIR/sqlite

# Wait till boot has completed'
(while [ 1 ]; do
if [ `getprop sys.boot_completed` = 1 ]; then sleep 60

# Disable service that populates database
# (in investigation..)
	
# Stop playstore to make changes
	am force-stop com.android.vending
# Change directory'
	cd $MODDIR

# Detach following apps from market
