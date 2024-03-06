#!/bin/sh

#==================================================================
# description     :This script will find the average temperature of
#                  the CPU and trigger a Telegram notification if
#                  this temperature exceeds a set limit ($alert).
#==================================================================

# Set the following number to the temperature (°C) at which you would like to receive alerts
alert=57.0

# Get number of CPU cores
ncpu=$(sysctl hw.ncpu | awk '{ print $2 }')

# Set hostname
thishost=$(hostname)

# Get temperature
get_temp() {
        avg=0

        for c in $(jot ${ncpu} 0); do
                temp=$(sysctl dev.cpu.${c}.temperature | sed -e 's|.*: \([0-9.]*\)C|\1|')
                avg=$(echo "${avg} + ${temp}" | bc | awk '{printf "%.1f", $0}')
        done

        avg=$(echo "${avg} / (${ncpu})" | bc | awk '{printf "%.1f", $0}')
}

# Define the number of iterations and sleep time
iterations=1
timeInSeconds=3

# Loop through the code block two times
for i in $(seq 1 1 $iterations); do
        get_temp

        # Compare the current average temperature to the alert threshold; send a Telegram notification if it's equal to or exceeds the threshold
        if [ "$(echo "$avg > $alert" | bc -l)" -eq 1 ]; then
                #echo "WARNING: ${thishost} is currently at ${avg}C, which is over the alert threshold of ${alert}C"

                # Uncomment the following lines if you want feedback on the console
                #echo "WARNING: ${thishost} is currently at ${avg}C, which is over the alert threshold of ${alert}C" >>pftemp_alert.txt
                #wall pftemp_alert.txt
                #rm pftemp_alert.txt
                php -r 'require_once("/etc/inc/notices.inc"); notify_via_telegram("\u{203C}\u{FE0F} High temp warning: '${avg}'\u{2103} \u{203C}\u{FE0F}");'
        fi

        sleep $timeInSeconds
done

exit 0

curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/33c45928-c63e-42de-9f74-fbaa621353f6/$?