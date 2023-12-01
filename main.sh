#!/usr/bin/bash

# Xerox

#/etc/uwuscan/mfd/XeroxVersaLinkB405.pl
#/etc/uwuscan/mfd/XeroxWorkCentre3615.pl

# executing scripts to create a log file for each printer
perl /etc/uwuscan/mfd/XeroxVersaLinkB405.pl
perl /etc/uwuscan/mfd/XeroxWorkCentre3615.pl

#/var/uwuscan_log/*.txt

function notify_in_telegram() {
  API_TOKEN="your_api_token"  # your tg bot API token
  CHAT_ID="your_chat_id"  # your tg chat ID

  # Send the message
  curl -s -X POST "https://api.telegram.org/bot$API_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE"
}

function check_last_log() {
  LOG_FILE=$FILE

  # Get the last log entry
  LAST_LOG=$(tac $LOG_FILE | awk '/---/{exit} 1' | tac)

  # Extract the printer name, cartridge and drum status
  PRINTER_NAME=$(echo "$LAST_LOG" | awk -F': ' '/Printer Nsame/{print $2}')
  CARTRIDGE_STATUS=$(echo "$LAST_LOG" | awk -F': ' '/Status cartridge/{print $2}' | tr -d '%')
  DRUM_STATUS=$(echo "$LAST_LOG" | awk -F': ' '/Status drum/{print $2}' | tr -d '%')

  # Check if the cartridge or drum status is less than 20%
  if [ "$CARTRIDGE_STATUS" -le 20 ] || [ "$DRUM_STATUS" -le 20 ]; then
    MESSAGE="wawning: cawtwidge or dwum status in $PRINTER_NAME is less than 20%!!! please wepwace it!!! owo"
    notify_in_telegram "$MESSAGE"
  elif [ "$CARTRIDGE_STATUS" -le 30 ] || [ "$DRUM_STATUS" -le 30 ]; then
    MESSAGE="wawning: cawtwidge or dwum status in $PRINTER_NAME is less than 30%. wepwacement will be needed soon uwu~"
    notify_in_telegram "$MESSAGE"
  else
    MESSAGE="$PRINTER_NAME is fine uwu~"
    notify_in_telegram "$MESSAGE"
  fi
}

for file in /var/uwuscan_log/*.txt; do
  check_last_log "$file"
done

