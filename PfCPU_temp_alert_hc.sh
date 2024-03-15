#!/bin/sh

#==================================================================
# description     :This script will find the average temperature of
#                  the CPU and trigger a Telegram notification if
#                  this temperature exceeds a set limit ($alert).
#                  The health check feature is integrated with the
#                  temperature monitor.
#==================================================================

# Set your healthchecks.io parameters
hcPingDomain="https://hc-ping.com/"
hcUUID=""

output=$({

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
        iterations=5
        timeInSeconds=60

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
} 2>&1)

# Exit status logic
exitStatus=${PIPESTATUS[0]}

if [ -z "$output" ]; then
        curl -fsS --retry 3 "${hcPingDomain}${hcUUID}/${exitStatus}"
else
        if [ "$exitStatus" -eq 0 ]; then
                curl -fsS --retry 3 --data-raw "${output}" "${hcPingDomain}${hcUUID}/fail"
        else
                curl -fsS --retry 3 --data-raw "${output}" "${hcPingDomain}${hcUUID}/${exitStatus}"
        fi
fi
