#!/bin/bash

# Create a macvlan interface for the host itself
ip link add macvlan-host link enp1s0 type macvlan mode bridge
ip addr add 192.168.8.4/24 dev macvlan-host
ip link set macvlan-host up

# Create a route so host traffic can reach the macvlan network
ip route add 192.168.8.0/24 dev macvlan-host

