#!/usr/bin/bash

# Xerox

#/etc/uwuscan/mfd/XeroxVersaLinkB405.pl
#/etc/uwuscan/mfd/XeroxWorkCentre3615.pl

# executing scripts to create a log file for each printer
#perl /etc/uwuscan/mfd/XeroxVersaLinkB405.pl
#perl /etc/uwuscan/mfd/XeroxWorkCentre3615.pl

#/var/uwuscan_log/*.txt

function notify_in_telegram() {
  API_TOKEN="your_api_token"  # your tg bot API token
  CHAT_ID="your_chat_id"  # your tg chat ID
  echo "$MESSAGE"
  # send the message
  curl -s -X POST "https://api.telegram.org/bot$API_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE"
}

function log_parser() {
  LOG_FILE="$file"
  NUMBER_OF_PRINTERS=1 #number of pwintews in a single log file(idk why i made this)
  PRINTER_NAME=""
  CARTRIDGE_STATUS=0
  DRUM_STATUS=0
    while IFS= read -r line; do
  if [[ $line == "Printer Name: "* ]]; then
    PRINTER_NAME=${line#*: }
  elif [[ $line == "Status cartridge: "* ]]; then
    CARTRIDGE_STATUS=${line#*: }
    CARTRIDGE_STATUS=${CARTRIDGE_STATUS//%/}
  elif [[ $line == "Status drum: "* ]]; then
    DRUM_STATUS=${line#*: }
    DRUM_STATUS=${DRUM_STATUS//%/}
  fi
done < <(tac "$LOG_FILE" | awk -v segments="$NUMBER_OF_PRINTERS" '/---/{if(seen++ == segments) exit} 1' | tac)
}

check_last_log() {
    log_parser
  MESSAGE=""
  # check if the cartridge or drum status is less than 20%
  if [ "$CARTRIDGE_STATUS" -lt 20 ] || [ "$DRUM_STATUS" -lt 20 ]; then
    MESSAGE=$(echo "wawning: cawtwidge or dwum status in $PRINTER_NAME is less than 20%!!! please wepwace it!!! owo")
    notify_in_telegram "$MESSAGE"
  elif [ "$CARTRIDGE_STATUS" -lt 30 ] || [ "$DRUM_STATUS" -lt 30 ]; then
    MESSAGE=$(echo "wawning: cawtwidge or dwum status in $PRINTER_NAME is less than 30%. wepwacement will be needed soon uwu~")
    notify_in_telegram "$MESSAGE"
  else
    MESSAGE=$(echo "$PRINTER_NAME is fine uwu~")
    notify_in_telegram "$MESSAGE"
  fi
}


for file in /var/uwuscan_log/*.txt; do
  check_last_log "$file"
done
