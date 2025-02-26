#!/bin/bash

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
  ovn-nbctl lsp-add ${switch} ${name} -- lsp-set-addresses ${name} "${mac} ${ip}"
}
encap_ip=$(ip -4 addr show dev br-ext | grep inet | cut -f6 -d' ' | cut -f1 -d'/')

ovn-nbctl ls-add sw0 -- set logical_switch sw0 other-config:subnet="10.0.0.0/24"
add_pod sw0 cont0 10.0.0.2 10.0.0.1 "0a:58:0a:f4:00:02"

ovn-nbctl lr-add lr0
#
# Connect sw0 to lr0
ovn-nbctl lrp-add lr0 lr0-sw0 00:00:00:00:ff:01 10.0.0.1/24 \
	-- lsp-add sw0 sw0-lr0 \
	-- lsp-set-type sw0-lr0 router \
	-- lsp-set-addresses sw0-lr0 00:00:00:00:ff:01 \
	-- lsp-set-options sw0-lr0 router-port=lr0-sw0


# Create a switch, public, for external connectivity, with a localnet port
ovn-nbctl ls-add public
ovn-nbctl lsp-add public ln-public \
	-- lsp-set-type ln-public localnet \
	-- lsp-set-addresses ln-public unknown \
	-- lsp-set-options ln-public network_name=provider

ovn-nbctl lrp-add lr0 lr0-public 00:00:20:20:12:13 10.88.0.200/16 \
	-- lsp-add public public-lr0 \
	-- lsp-set-type public-lr0 router \
	-- lsp-set-addresses public-lr0 00:00:20:20:12:13 \
	-- lsp-set-options public-lr0 router-port=lr0-public

# Create distributed gateway port (non-HA)
#ovn-nbctl set logical_router_port lr0-public options:redirect-chassis=master
ovn-nbctl set logical_router_port lr0-public options:gateway_chassis=master
ovn-nbctl lrp-set-gateway-chassis lr0-public master 20

# Configure NAT and default router in lr0
ovn-nbctl lr-route-add lr0 "0.0.0.0/0" ${encap_ip} \
	-- lr-nat-add lr0 snat 10.88.0.200 10.0.0.0/24
