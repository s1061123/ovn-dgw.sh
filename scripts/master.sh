#!/bin/bash

. common.sh

/usr/share/ovn/scripts/ovn-ctl --no-monitor start_nb_ovsdb
/usr/share/ovn/scripts/ovn-ctl --no-monitor start_sb_ovsdb
/usr/share/ovn/scripts/ovn-ctl --no-monitor start_northd
/usr/share/ovn/scripts/ovn-ctl --no-monitor start_controller

# allow external connection
ovn-nbctl set-connection ptcp:6641
ovn-sbctl set-connection ptcp:6642
ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6640

# configure ovn master
encap_ip=$(ip -4 addr show dev eth0 | grep inet | cut -f6 -d' ' | cut -f1 -d'/')
ovs-vsctl set Open_vSwitch . \
    external_ids:system-id=master \
    external_ids:ovn-remote=unix:/var/run/ovn/ovnsb_db.sock \
    external_ids:ovn-encap-type=geneve \
    external_ids:ovn-bridge-mappings=provider:br-ext \
    external_ids:ovn-encap-ip=${encap_ip}

ovs-vsctl --may-exist add-br br-ext
ovs-vsctl --may-exist add-port br-ext eth0
move_ip_to_ovn_bridge

#echo "${encap_ip}"
