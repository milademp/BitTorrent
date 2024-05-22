#!/bin/bash

echo "Updating package lists..."
apt-get update -y

# Open SSH Port
ufw allow ssh
echo "Opening SSH Port..."

# Disable UFW before making changes
ufw disable

# Set default policies
ufw default deny

# Ask for the port number to block
read -p "Enter the port number to block (press Enter for all ports): " port_number

# List of IP ranges to block
ip_ranges=(
  "200.0.0.0/8"
  "102.0.0.0/8"
  "10.0.0.0/8"
  "100.64.0.0/10"
  "169.254.0.0/16"
  "198.18.0.0/15"
  "198.51.100.0/24"
  "203.0.113.0/24"
  "224.0.0.0/4"
  "240.0.0.0/4"
  "255.255.255.255/32"
  "192.0.0.0/24"
  "192.0.2.0/24"
  "127.0.0.0/8"
  "127.0.53.53"
  "192.168.0.0/16"
  "0.0.0.0/8"
  "172.16.0.0/12"
  "224.0.0.0/3"
  "192.88.99.0/24"
  "198.18.140.0/24"
  "102.230.9.0/24"
  "102.233.71.0/24"
  "102.236.0.0/16"
  "2.60.0.0/16"
  "5.1.41.0/12"
)

# Block traffic to specified IP ranges on specified port or all ports
if [ -n "$port_number" ]; then
  for ip_range in "${ip_ranges[@]}"; do
    ufw deny out to $ip_range port $port_number
  done
else
  for ip_range in "${ip_ranges[@]}"; do
    ufw deny out to $ip_range
  done
fi

echo "Blocking outgoing traffic to specified IP ranges on port $port_number is complete."

# Save iptables rules
echo "Saving iptables rules..."
iptables-save > /etc/iptables/rules.v4

# Enable UFW
echo "Enabling UFW..."
ufw enable

# Add the service file
echo "[Unit]
Description=Firewall Setup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /root/abuse.sh

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/firewall-setup.service > /dev/null

# Reload systemd to load the new service file
systemctl daemon-reload

# Enable and start the service
systemctl enable firewall-setup.service
systemctl start firewall-setup.service

# Finish
echo "Script execution completed successfully."