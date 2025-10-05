#!/bin/bash
set -e

NETWORK=${NETWORK:-192.168.8.0/24}
CACHE_SIZE=${CACHE_SIZE:-100}

if [ -f /var/run/squid.pid ]; then
    echo "Removing old PID files"
    rm -f /var/run/squid.pid
fi

mkdir -p /var/cache/squid /var/log/squid /var/run/squid
chown -R squid:squid /var/cache/squid /var/log/squid /var/run/squid

cat > /etc/squid/squid.conf <<EOF
http_port 3128
acl localnet src $NETWORK
http_access allow localnet
http_access deny all

cache_mem 50 MB
maximum_object_size_in_memory 1 MB
cache_dir ufs /var/cache/squid $CACHE_SIZE 16 256
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
EOF

echo "cache init....."
squid -z

if [ -f /var/run/squid.pid ]; then
    echo "Removing old PID files"
    rm -f /var/run/squid.pid
fi

echo "starting squid"
exec squid -N -d 1
