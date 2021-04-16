#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk change its mount point in the future

MODDIR=${0%/*}
# This script will be executed in late_start service mode. More info in the main Magisk thread
# Detach Apps from Market by hinxnz

MAGMOD=/data/adb/modules/Detach

#Let boot status 
i=0
# Wait till boot has completed'
(while [ 1 ]; do

	
	sleep 5

	if [ `getprop sys.boot_completed` = 1 ]; then 
	
		((i++))
		if [[ $i -gt 1 ]]; then
			break
		fi
		#Reserved for crond schedule
		
		
		#prevent recursive run
		su -c sh "$MAGMOD/main.sh" > "$MAGMOD/first_detach_result.txt" 2>&1
		
	fi
	
done &)