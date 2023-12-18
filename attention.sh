#!/usr/bin/bash

#/var/uwuscan_log/*.txt

function notify_in_telegram() {
  API_TOKEN="your_api_token"  # your tg bot API token
  CHAT_ID="your_chat_id"  # your tg chat ID
  echo "$MESSAGE"
  # send the message
  curl -s -X POST "https://api.telegram.org/bot$API_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE"
}

check_last_log() {
  MESSAGE=""
  # check if the cartridge or drum status is less than 20%
  if [ "$CARTRIDGE_STATUS" -lt 20 ] || [ "$DRUM_STATUS" -lt 20 ]; then
    MESSAGE=$(echo -e "wawning: cawtwidge or dwum status in $PRINTER_NAME is less than 20%!!! please wepwace it!!! owo\ntimestamp: $(date +"%d/%m/%Y %H:%M")")
    notify_in_telegram "$MESSAGE"
  elif [ "$CARTRIDGE_STATUS" -lt 30 ] && [ "$CARTRIDGE_STATUS" -gt 20 ] || [ "$DRUM_STATUS" -lt 30 ] && [ "$CARTRIDGE_STATUS" -gt 20 ]; then
    MESSAGE=$(echo -e "wawning: cawtwidge or dwum status in $PRINTER_NAME is less than 30%. wepwacement will be needed soon uwu~\ntimestamp: $(date +"%d/%m/%Y %H:%M")")
    notify_in_telegram "$MESSAGE"
  else
    MESSAGE=$(echo "$PRINTER_NAME is fine uwu~")
  fi
}

function log_parser() {
  LOG_FILE="$file"
  PRINTER_NAME=""
  CARTRIDGE_STATUS=0
  DRUM_STATUS=0
  TODAY=$(date "+%a %b  %d")
  echo "$TODAY"
      while IFS= read -r line; do
        if [[ $line == "Printer Name: "* ]]; then
          PRINTER_NAME=${line#*: }
          echo "$PRINTER_NAME"
        elif [[ $line == "Status cartridge: "* ]]; then
          CARTRIDGE_STATUS=${line#*: }
          CARTRIDGE_STATUS=${CARTRIDGE_STATUS//%/}
          echo "$CARTRIDGE_STATUS"
          check_last_log
        elif [[ $line == "Status drum: "* ]]; then
          DRUM_STATUS=${line#*: }
          DRUM_STATUS=${DRUM_STATUS//%/}
          echo "$DRUM_STATUS"
          check_last_log
    fi
      done < <( tac "$LOG_FILE" | awk -v date="$TODAY" 'BEGIN{RS="---"} $0 ~ date' | tac )
}




for file in /var/uwuscan_log/*.txt; do
echo "$file"
  log_parser "$file"
done
