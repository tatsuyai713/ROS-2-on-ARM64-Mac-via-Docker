#!/bin/sh
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
cd $SCRIPT_DIR

cd files

CONTAINER_NAME="development-container-for-ros-2-on-m1-2-mac-x86_64_for_${USER}_container"

if [ "$(docker ps -al | grep ${CONTAINER_NAME})" ]; then
    ./launch_container.sh
else
    echo "Please start container first!"
fi
