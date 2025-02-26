# ovn-dgw.sh

## What's that?

These shell scripts
- launch podman container (to represent ovs/ovn node),
- setup ovs and ovn,
- launch ip-netns container to simulate VM/container in ovn,
- and setup distributed router port (DGP)

## Requriement

- podman
- sudo privilege

## Prerequisites

This script assumes that

- `10.88.0.0/16` is used for podman
- `10.88.0.200` is not used in podman network

if you need to change, please change in `scripts/pod-master.sh`.

## How to run the script

```
# Build container image first
$ ./build.sh

# startup with built container above
$ ./run.sh

# login to master
$ sudo podman exec -it master bash

# login to worker
$ sudo podman exec -it worker bash

# check ip-netns container
$ sudo podman exec <master or worker> ip netns

# login ip-netns container
$ sudo podman exec -it <master or worker> ip netns <netns name> bash

# kill master/worker podman container
$ ./kill.sh
```


## Acknowledgement

This repository utilizes scripts in [ovn-fun](https://github.com/dcbw/ovn-fun).
Thanks @dcbw for the awesome simple and good scripts!
