#!/bin/bash

. common.sh

if [ $# -ne 1 ]; then
	echo "usage: $0 <master ip>"
	exit
fi

/usr/share/ovn/scripts/ovn-ctl --no-monitor start_controller
master_ip="$1"
encap_ip=$(ip -4 addr show dev eth0 | grep inet | cut -f6 -d' ' | cut -f1 -d'/')

ovs-vsctl set Open_vSwitch . \
    external_ids:system-id=worker1 \
    external_ids:ovn-nb=tcp:${master_ip}:6641 \
    external_ids:ovn-remote=tcp:${master_ip}:6642 \
    external_ids:ovn-encap-type=geneve \
    external_ids:ovn-bridge-mappings=provider:br-ext \
    external_ids:ovn-encap-ip=${encap_ip}

ovs-vsctl --may-exist add-br br-ext
ovs-vsctl --may-exist add-port br-ext eth0
ovs-vsctl br-set-external-id br-ext bridge-id br-ext
move_ip_to_ovn_bridge

