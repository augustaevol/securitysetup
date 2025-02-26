#!/bin/bash

#Colors
MAGENTA="\e[35m"
CYAN="\e[36m"
GREEN="\e[32m"
RESET="\e[0m"

echo -e "${MAGENTA}Starting Security Setup..${RESET}"


# 1. Change MAC Adress
echo -e "${CYAN}Changing MAC Address..${RESET}"
sudo ifconfig eth0 down
sudo macchanger -r eth0
sudo ifconfig eth0 up
echo -e "${GREEN}New MAC Address Applied.${RESET}"

# 2. Kill unnecessary process
echo -e "${CYAN}Stopping unnecessary services..${RESET}"
sudo systemctl stop avahi-daemon
sudo systemctl disable avahi-daemon
echo -e "${GREEN}Unnecessary services stopped.${RESET}"

# 4. Disable SSH if running
echo -e "${CYAN}Disabling SSH..${RESET}"
sudo systemctl stop ssh
sudo systemctl disable ssh
echo -e "${GREEN}SSH has been disabled.${RESET}"

# 5. Check for rootkits (only if rkhunter is installed)
if command -v rkhunter &> /dev/null
then
    echo -e "${CYAN}Running rootkit check...${RESET}"
    sudo rkhunter --check --sk
    echo -e "${GREEN}Rootkit scan completed.${RESET}"
else
    echo -e "${MAGENTA}rkhunter not installed. Skipping rootkit scan.${RESET}"
fi

echo -e "${MAGENTA}Security Setup Complete!${RESET}"

# 6. Running Tor
echo -e "${CYAN}Checking Tor status...${RESET}"
if ! systemctl is-active --quiet tor; then
    echo -e "${MAGENTA}Tor is not running. Installing & starting...${RESET}"
    sudo apt update && sudo apt install -y tor
    sudo systemctl enable --now tor
else
    echo -e "${GREEN}Tor is already running.${RESET}"
fi

# 7. ProxyChains Setup
echo -e "${CYAN}Configuring ProxyChains...${RESET}"
sudo sed -i 's/^socks4 127.0.0.1 9050/socks5 127.0.0.1 9050/' /etc/proxychains.conf
sudo sed -i 's/#dynamic_chain/dynamic_chain/' /etc/proxychains.conf
echo -e "${GREEN}ProxyChains configured.${RESET}"

# 7️⃣ Test: IP über ProxyChains abrufen
echo -e "${CYAN}Testing anonymous connection...${RESET}"
proxychains curl ifconfig.me
