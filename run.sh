#!/bin/bash

# Check openvswitch module is already loaded
if ! grep -q "^openvswitch " /proc/modules ; then
    echo "openvswitch module not found."
    echo "Run \"sudo modprobe openvswitch\" before running the container"
    exit 1
fi

# startup podman containers (master, worker)
for i in master worker; do
	echo "INFO: $i started"
	sudo podman run --rm --privileged -d --name $i localhost/ovn-fun:multinode
	echo ""
	echo "INFO: $i ovs/ovn started"
	sudo podman exec $i ./startup.sh
done

echo ""
echo "INFO: setup ovn config"
sudo podman exec master ./master.sh
master_ip=$(sudo podman exec master ip -4 addr show dev br-ext | grep inet | cut -f6 -d' ' | cut -f1 -d'/')
sudo podman exec worker ./client.sh ${master_ip}

echo ""
echo "INFO: launch netns container"
sudo podman exec master ./pod-master.sh
sudo podman exec worker ./pod-worker1.sh ${master_ip}

sudo ip route add 10.0.0.0/24 via ${master_ip}
