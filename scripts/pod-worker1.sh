#!/bin/bash

if [ $# -ne 1 ]; then
	echo "usage: $0 <master ip>"
	exit
fi

master_nb=$1

add_pod() {
  local switch=${1}
  local container=${2}
  local ip=${3}
  local gw=${4}
  local mac=${5}
  local name="${switch}-${container}"

  ip netns add ${name}
  ip link add dev cont0 type veth peer name ${name}
  ip link set cont0 up
  ip link set ${name} up
  ip link set dev cont0 netns ${name}
  ip netns exec ${name} ip link set dev cont0 name eth0
  ip netns exec ${name} ip link set dev eth0 address ${mac}
  ip netns exec ${name} ip link set dev eth0 up
  ip netns exec ${name} ip link set lo up
  ip netns exec ${name} ip addr add ${ip}/24 dev eth0
  ip netns exec ${name} ip route add default dev eth0 via ${gw}

  ovs-vsctl add-port br-int ${name} -- set interface ${name} external_ids:iface-id=${name}
  ovn-nbctl --db=tcp:${master_nb}:6641 lsp-add ${switch} ${name} -- lsp-set-addresses ${name} "${mac} ${ip}"
}

add_pod sw0 cont1 10.0.0.3 10.0.0.1 "0a:58:0a:f4:00:03"
