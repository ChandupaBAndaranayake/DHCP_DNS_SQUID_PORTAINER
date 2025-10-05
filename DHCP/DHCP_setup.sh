#!/bin/bash
set -e

RANGE_START=${RANGE_START:-192.168.8.130}
RANGE_END=${RANGE_END:-192.168.8.160}
ROUTER=${ROUTER:-192.168.8.1}
DNS_SERVER=${DNS_SERVER:-192.168.8.132}
LEASE_TIME=${LEASE_TIME:-43200} # 12h

mkdir -p /etc/dhcp
touch /etc/dhcp/dhcpd.leases

cat > /etc/dhcp/dhcpd.conf <<EOF
default-lease-time $LEASE_TIME;
max-lease-time $((LEASE_TIME*2));
authoritative;

subnet 192.168.8.0 netmask 255.255.255.0 {
  range $RANGE_START $RANGE_END;
  option routers $ROUTER;
  option domain-name-servers $DNS_SERVER;
}
EOF

exec dhcpd -f -d -cf /etc/dhcp/dhcpd.conf -lf /etc/dhcp/dhcpd.leases
