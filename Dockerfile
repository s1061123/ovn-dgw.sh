# https://github.com/dcbw/ovn-fun
FROM fedora:40

MAINTAINER Tomofumi Hayashi <tohayash@redhat.com>

RUN dnf -y upgrade && \
	dnf -y install openvswitch-test iputils tcpdump ovn ovn-central ovn-host \
		procps-ng less util-linux bind-utils wireshark && \
	dnf clean all -y
RUN rm -f /root/*

COPY scripts/* /root

WORKDIR /root
ENTRYPOINT /bin/bash -c 'sleep infinity'
