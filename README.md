````markdown
# DHCP, DNS, SQUID, PORTAINER Setup

This repository contains a ready-to-run Docker Compose setup for a **local lab network environment**. It includes:

- **DNS Server** (`alpine_dns`)  
- **DHCP Server** (`alpine_dhcp`)  
- **Squid Proxy** (`alpine_squid`)  
- **Portainer** (`portainer`) for Docker management  

The stack uses a **macvlan network** to allow containers to have IPs on the same subnet as the host.

---

## Table of Contents

- [Requirements](#requirements)  
- [Host Machine Setup](#host-machine-setup)  
- [Macvlan Setup](#macvlan-setup)  
- [Docker Compose Setup](#docker-compose-setup)  
- [Testing the Stack](#testing-the-stack)  
- [Accessing Services](#accessing-services)

---

## Requirements

- Ubuntu 22.04 LTS host  
- Docker Engine >= 20.10  
- Docker Compose >= 2.x  

---

## Host Machine Setup

### 1. Configure systemd-resolved to use the DNS container

Edit `/etc/systemd/resolved.conf`:

```bash
sudo nano /etc/systemd/resolved.conf
````

Add/modify the following:

```ini
[Resolve]
DNS=192.168.8.132
FallbackDNS=8.8.8.8 8.8.4.4
DNSStubListener=no
```

Save and restart systemd-resolved:

```bash
sudo systemctl restart systemd-resolved
sudo systemctl status systemd-resolved
```

> **Explanation:** This points your host to the **DNS container IP** first and falls back to Google DNS if needed.

---

## Macvlan Setup

Create a macvlan interface for the host to communicate with the container network.

Create a script `/usr/local/bin/macvlan.sh`:

```bash
sudo nano /usr/local/bin/macvlan.sh
```

Paste the following:

```bash
#!/bin/bash

# Create a macvlan interface for the host
ip link add macvlan-host link enp1s0 type macvlan mode bridge
ip addr add 192.168.8.4/24 dev macvlan-host
ip link set macvlan-host up

# Add route so host traffic can reach the macvlan network
ip route add 192.168.8.0/24 dev macvlan-host
```

Make the script executable and run it:

```bash
sudo chmod +x /usr/local/bin/macvlan.sh
sudo /usr/local/bin/macvlan.sh
```

> **Explanation:**
>
> * `enp1s0` → replace with your host's main network interface
> * `192.168.8.4` → host’s macvlan IP (must be free in your subnet)

---

## Docker Compose Setup

### 1. Clone this repository

```bash
git clone git@github.com:yourusername/vcct_setup.git
cd vcct_setup
```

### 2. Pull or Build Images

If using **prebuilt Docker Hub images**:

```bash
docker compose pull
```

If building locally:

```bash
docker compose up -d --build
```

### 3. Verify Containers

```bash
docker ps
```

Expected containers:

* `alpine_dns` → DNS server
* `alpine_dhcp` → DHCP server
* `alpine_squid` → Squid proxy
* `portainer` → Docker management UI

---

## Testing the Stack

### 1. Test Squid Proxy from a container:

```bash
docker run --rm --net VCCT_macvlan alpine:latest \
    sh -c "apk add --no-cache curl && curl -x http://192.168.8.6:3128 http://example.com"
```

### 2. Check Squid logs:

```bash
docker exec -it alpine_squid tail -f /var/log/squid/access.log
```

### 3. Configure Firefox Proxy:

* **HTTP Proxy / SOCKS:** `192.168.8.6`
* **Port:** `3128`
* **No proxy for:** `127.0.0.1, localhost, 192.168.8.0/24`

---

## Accessing Portainer

Open in a browser:

```
http://<host-ip>:9000
```

* Use Portainer to manage containers and images via Web UI.

---

## Notes

* Make sure all IPs (`192.168.8.x`) match your local subnet and are **not conflicting**.
* If host cannot reach containers, re-run `macvlan.sh` and check the route.
* For production or lab use, consider adding persistent volumes and security hardening.


