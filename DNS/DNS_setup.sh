#!/bin/bash

DNS_DOMAIN=${DNS_DOMAIN:-csne.vcct.com}
DNS_IP=${DNS_IP:-192.168.8.132}
NETWORK=${NETWORK:-192.168.8.0/24}

if [ -d /etc/bind ]; then
    echo "/etc/bind is chilling :)"
else
    echo "/etc/bind is missing :("
    mkdir -p /etc/bind
fi

cat > /etc/bind/named.conf <<EOF
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
EOF

cat > /etc/bind/named.conf.local <<EOF
zone "$DNS_DOMAIN" {
    type master;
    file "/etc/bind/db.$DNS_DOMAIN";
};
EOF

cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/etc/bind";
    listen-on { any; };
    listen-on-v6 { none; };
    allow-query { $NETWORK; };
    recursion yes;
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };
};
EOF

cat > /etc/bind/db.$DNS_DOMAIN << EOF
\$TTL 604800
@   IN  SOA ns.$DNS_DOMAIN. admin.$DNS_DOMAIN. (
            2 604800 86400 2419200 604800 )
@   IN  NS  ns.$DNS_DOMAIN.
ns  IN  A   $DNS_IP
$DNS_DOMAIN. IN A $DNS_IP
EOF

exec named -g -c /etc/bind/named.conf
