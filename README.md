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
sudo pacman -S perl-net-snmp perl-log-any
```
Or else

```bash
sudo apt-get install libnet-snmp-perl liblog-any-perl
```

4. Copy the script directory to /etc and make them executable:

```bash
sudo cp -r uwuscan/ /etc/ && sudo chmod +x /etc/uwuscan/mfd/*
```

5. Uncomment in main.sh the scripts you need;
6. Specify the necessary ip addresses in the scripts;
7. Add main.sh in your favorite time-based job scheduler.

## Telegram Notifications

To enable notifications in Telegram, enable attention.pl in main.sh

### Configuring the script

In attention.pl in `my $url = 'https://api.telegram.org/bot<token>/sendMessage';`, specify the bot token, and in `my $chat_id = '<chat id>';`, specify your chat ID.

# oid

snmpwalk installation

```bash 
sudo apt-get install snmp
```

or

```bash
sudo pacman -S net-snmp
```

Search oid

```bash
sudo snmpwalk -v 2c -c public {ip-address}
```
