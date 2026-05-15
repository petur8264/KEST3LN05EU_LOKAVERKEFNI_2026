#!/bin/bash
# Debian

echo "Setting up firewall on client1..."

# Reset UFW to clean state
ufw --force reset

# Default: block all incoming, allow all outgoing
ufw default deny incoming
ufw default allow outgoing

# SSH only
ufw allow 22/tcp

# Enable firewall
ufw --force enable

echo "Done! Open ports on client1:"
ufw status verbose


#!/bin/bash
# Red Hat

echo "Setting up firewall on client2..."

# Make sure firewalld is running
systemctl start firewalld
systemctl enable firewalld

# Remove all default services
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client
firewall-cmd --permanent --zone=public --remove-service=cockpit

# Remove port 514 explicitly (syslog)
firewall-cmd --permanent --zone=public --remove-port=514/tcp
firewall-cmd --permanent --zone=public --remove-port=514/udp

# Allow SSH only
firewall-cmd --permanent --zone=public --add-service=ssh

# Apply changes
firewall-cmd --reload

echo "Done! Open ports on client2:"
firewall-cmd --list-all


#!/bin/bash
# Debian Server Firewall

echo "Setting up firewall on server1..."

# Reset UFW to clean state
ufw --force reset

# Default: block all incoming, allow all outgoing
ufw default deny incoming
ufw default allow outgoing

# SSH
ufw allow 22/tcp

# DNS (BIND9)
ufw allow 53/tcp
ufw allow 53/udp

# DHCP server (port 67 only — this machine is the server, not a client)
ufw allow 67/udp

# HTTP (Roundcube webmail)
ufw allow 80/tcp

# SMTP (Postfix)
ufw allow 25/tcp

# NTP
ufw allow 123/udp

# Syslog — UDP only
ufw allow 514/udp

# CUPS (printing)
ufw allow 631/tcp
ufw allow 631/udp

# Enable firewall
ufw --force enable

echo "Done! Open ports on server1:"
ufw status verbose
