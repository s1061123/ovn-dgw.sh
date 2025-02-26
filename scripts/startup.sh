#!/bin/bash

# Check openvswitch module is already loaded
#if ! grep -q "^openvswitch " /proc/modules ; then
#    echo "openvswitch module not found."
#    echo "Run \"sudo modprobe openvswitch\" before running the container"
#    exit 1
#fi

# Start OVS
mkdir -p /var/run/openvswitch
mkdir -p /var/log/openvswitch
/usr/bin/chown root:root /var/run/openvswitch /var/log/openvswitch
#/usr/share/openvswitch/scripts/ovs-ctl --no-ovs-vswitchd --no-monitor --system-id=random start
#/usr/share/openvswitch/scripts/ovs-ctl --no-ovsdb-server --no-monitor --system-id=random start
/usr/share/openvswitch/scripts/ovs-ctl --no-monitor --system-id=random start

mkdir -p /var/lib/ovn
mkdir -p /var/run/ovn
mkdir -p /etc/ovn
mkdir -p /usr/share/ovn

exit

exec /bin/bash
