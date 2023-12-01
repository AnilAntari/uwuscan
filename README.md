# uwuscan

uwuscan - a set of scripts for monitoring the status of network MFPs in the terminal.

## Install

1. Get the script:

```bash
git clone https://github.com/AnilAntari/uwuscan
```

2. Create directories for log files:

```bash
sudo mkdir /var/uwuscan_log
```

3. Installing the module:

```bash
sudo pacman -S perl-net-snmp
```
Or else

```bash
sudo apt install libnet-snmp-perl
```

4. Copy the script directory to /etc and make them executable:

```bash
sudo cp -r uwuscan/ /etc/ && sudo chmod +x /etc/uwuscan/mfd/*
```

5. Uncomment in main.sh the scripts you need;
6. Specify the necessary ip addresses in the scripts;
7. Add main.sh in your favorite time-based job scheduler.

## Telegram Notifications

To enable notifications in a Telegram, uncomment the line in main.sh:

```bash
etc/uwuscan/attention.sh
```

### Configuring the script

In attention.sh in API_TOKEN, specify the bot token, and in CHAT_ID, specify your chat ID. 

You can configure the trigger parameters for the bot:

```bash
[ "$CARTRIDGE_STATUS" -lt 20 ] || [ "$DRUM_STATUS" -lt 20 ]
```
