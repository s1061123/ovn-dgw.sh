#!/bin/sh

function move_ip_to_ovn_bridge() {
	encap_ip_cidr=$(ip -4 addr show dev eth0 | grep inet | cut -f6 -d' ')
	default_gw=$(ip -4 route show default 0.0.0.0/0 | cut -f3 -d ' ' | cut -f1 -d '/')
	#echo "XXX: encap_ip: ${encap_ip}, default_gw: ${default_gw}"

	ip -4 addr del ${encap_ip_cidr} dev eth0
	ip -4 addr add ${encap_ip_cidr} dev br-ext
	ip link set up br-ext
	ip -4 route add default via ${default_gw} dev br-ext
}
