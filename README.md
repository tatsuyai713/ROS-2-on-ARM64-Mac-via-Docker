# ROS on M1 Mac Docker with xrdp(ARM64)
 This docker file makes the container of ROS Melodic on Ubuntu 18.04 LTS for M1 Mac (ARM64) based on https://github.com/yama07/docker-ubuntu-lxde/tree/master/xrdp

## Recommend
 Use jammy_kde (include ROS2 Humble)

## How to use
1. Install docker developer preview for M1 Mac
2. Build container : excute "./launch_container.sh build" (for Japanese : "./launch_container.sh build JP")
3. To use bash only : "./launch_container.sh"
4. Commit docker container : "./launch_container.sh commit"
5. Use ROS with GUI : "./launch_container.sh xrdp" and use RDP Client(access to 127.0.0.1).

## RDP Client

- Microsoft Remote Desktop

Support sound but cannot input "_" by JP keyboard

- Parallels Client

Support "_" by JP keyboard but sound is not suported
