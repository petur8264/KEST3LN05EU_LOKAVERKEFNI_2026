# KEST3LN05EU_LOKAVERKEFNI_2026


# DDP Linux Infrastructure Project

## Executive Summary

This project builds a centralized Linux-based server infrastructure for DDP ehf. The goal of the project is to provide essential network services for a small company environment with approximately 30 employees across multiple departments.

The infrastructure is based on one central Ubuntu server and two Linux clients. The server provides core services such as DHCP, DNS, time synchronization, centralized logging, mail services, printing, SSH access, backups, and firewall protection.

The project was completed in a VMware lab environment using a private internal network for company services and a NAT adapter for server internet access.

---

## Project Overview

### Company

**DDP**

### Domain

**ddp.is**

### Systems

| Machine | Operating System | Hostname | Purpose |
|---|---|---|---|
| Server | Ubuntu Desktop(acting as server) | server1.ddp.is | Central management server |
| Client 1 | Linux Mint Debian | client1.ddp.is | Debian-based client |
| Client 2 | Rocky Linux | client2.ddp.is | Red Hat-based client |

---

## Network Design

server1 uses two network adapters:

| Interface | Network Type | Purpose | Configuration |
|---|---|---|---|
| ens33 | NAT | Internet access for updates/packages | DHCP |
| ens34 | Host-only/private | Internal company network | 192.168.100.10/24 |

The clients are connected to the private network only.

### Private Network

```text
192.168.100.0/24
