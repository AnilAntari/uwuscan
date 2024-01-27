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

To enable notifications in a Telegram, install rust-script and enable attention.rs in main.sh

1. Install rust-script

Using your package manager:
```bash
sudo pacman -S rust-script
```
Or using cargo:
```bash
# Don't forget to install rust/cargo
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo binstall --no-confirm rust-script
```
2. Uncomment these lines in main.sh and put your token and id in env vars
```bash
LOGS_DIR = /var/uwuscan_log
API_TOKEN = "Your telegram api token"
CHAT_ID = "Your telegram chat id"
/etc/uwuscan/attention.rs
```

### Configuring the script

In attention.rs in API_TOKEN, specify the bot token, and in CHAT_ID, specify your chat ID. 

You can configure the trigger parameters for the bot:

```rust
entry.cartrige < 20 || entry.drum < 20
```

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
