# PfSense-CPU-Temp-Alert (Tested on pfSense 2.7.2)

A straightforward script designed to alert you when your pfSense box surpasses a predefined temperature threshold.

- Copy the script to the local pfsense router.

  1. Login via ssh using root user and password.

  2. Select shell command `8`.

  3. Change your directory to /usr/local/bin.

  ```
  cd /usr/local/bin
  ```

  4. Download the script file.

  ```
  curl -LJO https://raw.githubusercontent.com/dmytrokoren/PfSense-CPU-Temp-Alert/main/PfCPU_temp_alert_hc.sh
  ```

  5. Install nano file editor

  ```
  pkg update
  pkg install nano
  ```

  6. Change 'hcUUID', 'alert', 'iterations' and 'timeInSeconds' using nano<br>
  Note: Need to sign up for healthchecks.io and copy UUID

  ```
  nano PfCPU_temp_alert_hc.sh
  ```

  7. (OPTONAL) Change the script to customize your experience.

     - Change 'alert', 'iterations' and 'timeInSeconds'.
     - Uncomment the print lines. if you want to see feedback on the console. But by-default it is off.

  8. After Pasting the Script. Press `ESC` then `:x` to exit from the vi editor.

- To test the script on your local pfsense box.

  1. Install bash, if not installed already.

  ```
  pkg install bash
  ```

  2. Change permisson to executable.

  ```
  chmod +x PfCPU_temp_alert_hc.sh
  ```

  3. Run it as "bash PfCPU_temp_alert_hc.sh".

  ```
  bash PfCPU_temp_alert_hc.sh
  ```

- To run the the script on your local pfsence box on schedule.

  1. Install cron, if not installed already.

  System > Package Manager > Available Packages > Search "cron" > install.

  2. Configure the cron service.

  Services > corn > add

  Then type as follows<br>
  (I'm setting 5 min cron job, as I have set iterations: 10, timeInSeconds: 30)<br>
  This will ping the healthchecks.io once every 5 min, but the CPU temp check will occur every 30 seconds.

      - Minute - 5
      - Hour - *
      - Day of the month - *
      - Month of the year - *
      - Day of the week - *
      - User -  root
      - Command - ``` bash /usr/local/bin/PfCPU_temp_alert_hc.sh ```

  3. Click on Save.

We have completed the setup. You will receive a Telegram notification if your system surpasses a specified temperature threshold, allowing prompt action to save your system. In addition, you will be able to monitor cron job ping via healthchecks.io

Feedback is always welcome.
