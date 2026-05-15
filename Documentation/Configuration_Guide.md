# Configuration Guide

## DDP Linux Infrastructure Project

This document explains the main configuration steps used in the DDP Linux Infrastructure Project. It lists the services configured, the important configuration files, and the commands used to verify that each part works.

---

## 1. Project Information

| Item | Value |
|---|---|
| Company | DDP ehf. |
| Domain | ddp.is |
| Server | server1.ddp.is |
| Client 1 | client1.ddp.is |
| Client 2 | client2.ddp.is |
| Private Network | 192.168.100.0/24 |
| Server Private IP | 192.168.100.10 |
| DNS Server | 192.168.100.10 |

---

## 2. Network Configuration

### Purpose

server1 was configured with two network adapters. One adapter is used for internet access and the other is used for the private company network.

### Server Network Adapters

| Interface | Type | Purpose | Configuration |
|---|---|---|---|
| ens33 | NAT | Internet access for updates and packages | DHCP |
| ens34 | Host-only / Private | Internal company network | 192.168.100.10/24 |

### Configuration File

```text
/etc/netplan/*.yaml
```

### Verification Commands

```bash
ip a
ip route
ping 192.168.100.10
ping google.com
```

### Evidence

Screenshots should show the server interfaces, IP addresses, and routing table.

---

## 3. Hostname and Domain Configuration

### Purpose

Each machine was given a hostname in the `ddp.is` domain.

### Hostnames

| Machine | Hostname |
|---|---|
| Server | server1.ddp.is |
| Client 1 | client1.ddp.is |
| Client 2 | client2.ddp.is |

### Commands Used

On server1:

```bash
sudo hostnamectl set-hostname server1.ddp.is
```

On client1:

```bash
sudo hostnamectl set-hostname client1.ddp.is
```

On client2:

```bash
sudo hostnamectl set-hostname client2.ddp.is
```

### Verification Commands

```bash
hostname
hostname -f
```

### Evidence

Screenshots should show correct hostnames on all three machines.

---

## 4. DHCP Server Configuration

### Purpose

The DHCP server on server1 automatically assigns IP addresses and network information to client1 and client2 on the private network.

### Service

```text
isc-dhcp-server
```

### Configuration Files

```text
/etc/dhcp/dhcpd.conf
/etc/default/isc-dhcp-server
```

### Example DHCP Settings

```conf
subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.200;
    option domain-name "ddp.is";
    option domain-name-servers 192.168.100.10;
    option routers 192.168.100.1;
}
```

### Verification Commands

```bash
systemctl status isc-dhcp-server
ip a
sudo dhcp-lease-list
cat /var/lib/dhcp/dhcpd.leases
```

### Evidence

Screenshots should show:

- DHCP service running
- DHCP configuration file
- successful DHCP lease from a client

---

## 5. DNS Server Configuration

### Purpose

BIND9 was configured on server1 to provide DNS resolution for the `ddp.is` domain.

The DNS server provides:

- forward lookup, for example `server1.ddp.is` to `192.168.100.10`
- reverse lookup, for example `192.168.100.10` to `server1.ddp.is`

### Service

```text
bind9
```

### Configuration Files

```text
/etc/bind/named.conf.local
/etc/bind/named.conf.options
/etc/bind/db.ddp.is
/etc/bind/db.192.168.100
```

### Verification Commands

```bash
systemctl status bind9
named-checkconf
named-checkzone ddp.is /etc/bind/db.ddp.is
nslookup server1.ddp.is
nslookup client1.ddp.is
nslookup client2.ddp.is
nslookup 192.168.100.10
```

### Evidence

Screenshots should show:

- BIND9 service running
- forward DNS lookup working
- reverse DNS lookup working

---

## 6. User Account Configuration

### Purpose

Thirty user accounts were created using an automated script. Users were placed into department groups.

### Script

```text
Scripts/create_users.sh
```

### Example Department Groups

```text
it
management
sales
finance
```

### Verification Commands

```bash
cat /etc/passwd
getent group
id username
```

### Evidence

Screenshots should show:

- user accounts created
- department groups created
- users assigned to groups

---

## 7. Backup Configuration

### Purpose

A backup script was created to back up all user home directories every Friday at midnight.

### Script

```text
Scripts/backup_home.sh
```

### Backup Schedule

```cron
0 0 * * 5 /path/to/backup_home.sh
```

### Verification Commands

```bash
crontab -l
ls -l /backup
ls -l /var/backups
```

### Evidence

Screenshots should show:

- backup script
- cron schedule
- backup file created after a test run

---

## 8. NTP / Time Synchronization

### Purpose

server1 was configured as the main time server. client1 and client2 synchronize their system time with server1.

### Service

The project used Linux time synchronization tools to synchronize client time with server1.

### Verification Commands

```bash
timedatectl
date
```

### Evidence

Screenshots should show:

- time service or time status on server1
- time synchronization result on client1
- time synchronization result on client2

---

## 9. Centralized Syslog Configuration

### Purpose

server1 was configured as a centralized Syslog server. client1 and client2 send logs to server1.

### Service

```text
rsyslog
```

### Server Configuration Files

```text
/etc/rsyslog.conf
/etc/rsyslog.d/10-remote-logs.conf
```

### Client Configuration File

```text
/etc/rsyslog.d/90-send-to-server.conf
```

### Server Remote Log Location

```text
/var/log/remote/
```

### Example Server Config

```conf
module(load="imudp")
input(type="imudp" port="514")

module(load="imtcp")
input(type="imtcp" port="514")
```

### Example Remote Log Rule

```conf
$template RemoteLogs,"/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log"

*.* ?RemoteLogs
& stop
```

### Example Client Config

```conf
*.* @@192.168.100.10:514
```

### Verification Commands

On the clients:

```bash
logger "SYSLOG TEST FROM CLIENT1"
logger "SYSLOG TEST FROM CLIENT2"
```

On server1:

```bash
systemctl status rsyslog
sudo ss -tulnp | grep 514
sudo ls -R /var/log/remote
sudo grep -R "SYSLOG TEST" /var/log/remote
```

### Evidence

Screenshots should show:

- rsyslog service running
- port 514 listening
- logs received from client1
- logs received from client2

---

## 10. Mail Server Configuration

### Purpose

Postfix was installed and configured on server1 for mail services in the `ddp.is` domain.

Roundcube webmail was installed or attempted as part of the mail service configuration.

### Service

```text
postfix
```

### Main Configuration Files

```text
/etc/postfix/main.cf
/etc/mailname
```

### Important Postfix Settings

```conf
myhostname = server1.ddp.is
mydomain = ddp.is
myorigin = /etc/mailname
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
inet_interfaces = all
inet_protocols = ipv4
```

### `/etc/mailname`

```text
ddp.is
```

### Verification Commands

```bash
systemctl status postfix
postconf -n
postconf -n | grep -E "myhostname|mydomain|myorigin|mydestination|inet_interfaces|inet_protocols"
echo "Postfix test" | mail -s "Test Mail" root
sudo tail -n 50 /var/mail/root
sudo grep "status=sent" /var/log/mail.log | tail
```

### Evidence

Screenshots should show:

- Postfix service running
- Postfix configuration values
- test mail received in `/var/mail/root`

### Note

Postfix local mail delivery was tested successfully. Roundcube browser-based webmail was not fully completed.

---

## 11. CUPS Printing Configuration

### Purpose

CUPS was configured to provide shared printing with group-based access control.

Only users in the correct department groups may print. IT and Management users have print and management permissions.

### Service

```text
cups
```

### Configuration File

```text
/etc/cups/cupsd.conf
```

### Printer Used

```text
DDP_PDF_Printer
```

### Department Groups

```text
it
management
sales
finance
```

### Important Commands

```bash
sudo apt install cups -y
sudo systemctl enable --now cups
sudo cupsctl --remote-admin --remote-any --share-printers
sudo systemctl restart cups
```

### Printer Commands

```bash
lpstat -p -d
lpstat -p DDP_PDF_Printer -l
lpstat -W completed
```

### Verification Commands

```bash
systemctl status cups
sudo ss -tulnp | grep 631
lpstat -p -d
lpstat -W completed
```

### Evidence

Screenshots should show:

- CUPS service running
- CUPS listening on port 631
- printer configured
- group-based access settings
- completed print job

---

## 12. SSH Hardening Configuration

### Purpose

SSH was hardened on server1, client1, and client2. Password authentication was disabled and RSA key-based authentication was used.

### Service

Ubuntu / Debian:

```text
ssh
```

Rocky Linux:

```text
sshd
```

### Configuration File

```text
/etc/ssh/sshd_config
```

### Important SSH Settings

```conf
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PermitRootLogin no
UsePAM yes
```

### RSA Key Generation

On client1 and client2:

```bash
ssh-keygen -t rsa -b 4096
```

### Copy Key to server1

```bash
ssh-copy-id server-admin@192.168.100.10
```

### Test Key Login

```bash
ssh server-admin@192.168.100.10
hostname
exit
```

### Test Password Login Disabled

```bash
ssh -o PubkeyAuthentication=no server-admin@192.168.100.10
```

Expected result:

```text
Permission denied
```

### Verification Commands

```bash
systemctl status ssh
systemctl status sshd
sudo sshd -t
sudo grep -E "PubkeyAuthentication|PasswordAuthentication|KbdInteractiveAuthentication|ChallengeResponseAuthentication|PermitRootLogin|UsePAM" /etc/ssh/sshd_config
```

### Evidence

Screenshots should show:

- SSH service running
- SSH config values
- successful RSA key login
- password login blocked

---

## 13. Firewall and Nmap Verification

### Purpose

Unused ports were closed and the final system was scanned with Nmap to verify exposed services.

### Firewall Tool

```text
ufw
```

### Verification Commands

```bash
sudo ufw status
sudo ufw status numbered
nmap 192.168.100.10
```

### Expected Open Ports

Depending on completed services, expected open ports may include:

| Port | Service |
|---|---|
| 22 | SSH |
| 25 | SMTP / Postfix |
| 53 | DNS |
| 67 | DHCP |
| 123 | NTP |
| 514 | Syslog |
| 631 | CUPS |

Only required service ports should remain open.

### Evidence

Screenshots should show:

- firewall status
- Nmap scan results
- only required services exposed

---

## 14. Evidence Locations

Project screenshots and evidence are stored in these folders:

```text
Documentation/Screenshots/
Evidence/service_status_screenshots/
Evidence/nmap_scans/
```

Important evidence includes:

- network interface configuration
- DHCP lease
- DNS lookup tests
- user creation verification
- backup execution
- time synchronization
- centralized Syslog logs
- Postfix mail test
- CUPS printer status
- SSH key login
- SSH password login blocked
- firewall status
- Nmap scan results

---

## 15. Summary

The configuration completed for this project includes:

- server and client hostnames
- private network setup
- DHCP server
- DNS server
- automated user creation
- scheduled backups
- time synchronization
- centralized logging
- Postfix mail service
- CUPS shared printing
- SSH hardening
- firewall and Nmap verification

This guide documents the main configuration files and verification commands used to prove that each service was configured correctly.
