#!/bin/sh

# Set your healthchecks.io parameters
hcPingDomain="https://hc-ping.com/"
hcUUID=""

m=$(/usr/local/bin/PfCPU_temp_alert_hc.sh 2>&1)
curl -fsS --retry 3 --data-raw "$m" "${hcPingDomain}${hcUUID}/$?"
