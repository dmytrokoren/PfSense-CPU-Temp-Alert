#!/bin/sh

#==================================================================
#description     :This script will find the average temperature of
#                 the CPU and fire off an telegram notification if
#                 this temperature is over a set limit ($alert).
#==================================================================

#Change the following number to the temperature you'd like to be alerted at
alert=55

#Get number of CPU cores
ncpu=$(sysctl hw.ncpu | awk '{ print $2 }')

#Set hostname
thishost=$(hostname)

#Get temperature
get_temp() {
        avg=0

        for c in $(jot ${ncpu} 0); do
                temp=$(sysctl dev.cpu.${c}.temperature | sed -e 's|.*: \([0-9.]*\)C|\1|')
                avg=$(echo "${avg} + ${temp}" | bc)
        done

        avg=$(echo "${avg} / (${ncpu})" | bc)
}

get_temp

#Compare current average temperature to alert threshold, telegram notify if equal or over
if [ "$avg" -gt "$alert" ]; then
        echo "WARNING: ${thishost} is currently at ${avg}C, which is over the alert threshold of ${alert}C"
        php -r 'require_once("/etc/inc/notices.inc"); notify_via_telegram("\u{00AC} ALERT \u{00AC}\nTemperature at '${avg}'\u{2103}");'
        exit 1
fi

exit 0
