# uwuscan

uwuscan - a set of scripts for monitoring the status of network MFPs in the terminal.

## Tools and libraries
* Perl
* Curl
* Log-Any
* Net-SNMP

## Install

1. Get the script:

```bash
git clone https://github.com/AnilAntari/uwuscan.git
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

5. Uncomment in main.sh the scripts you need.

## Script Configurations

Scripts are configured using modules (.pm), which are located in `/etc/uwuscan/parameters/MFD-Model/`. The module contains the oid and ip addresses of the MFD. Example:
```perl
package set;

our  @oid_list = (
  '1.3.6.1.2.1.43.11.1.1.8.1.1', # Cartridge max status 
  '1.3.6.1.2.1.43.11.1.1.9.1.1', # Cartridge current status  
  '1.3.6.1.2.1.43.11.1.1.8.1.6', # Drum max status  
  '1.3.6.1.2.1.43.11.1.1.9.1.6'  # Drum current status
);

our @ip_address = (
  '192.168.1.1',
  '192.168.1.2',
  '192.168.1.3'
);

1;
```
The main values listed in the `oid_list` array are: cartridge max status, cartridge current status. If you want to add or remove the OID from the `oid_list` array, then you will have to rewrite the script for which you changed the module.

The `ip_address` array contains MFD IP addresses.

## Telegram Notifications

To enable notifications in Telegram, enable attention.pl in main.sh

### Configuring the script

In attention.pl in `my $url = 'https://api.telegram.org/bot<token>/sendMessage';`, specify the bot token, and in `my $chat_id = '<chat id>';`, specify your chat ID.

You can configure the trigger parameters for the bot:
```perl
$cawtwidge < 20 || $dwum < 20
```

# oid

snmpwalk installation:

```bash 
sudo apt-get install snmp
```

or

```bash
sudo pacman -S net-snmp
```

Search oid:

```bash
sudo snmpwalk -Cc -c public -v2c -On ip-address
```
