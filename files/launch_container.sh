#!/bin/sh
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
cd $SCRIPT_DIR

NAME_IMAGE="development-container-for-ros-2-on-m1-2-mac-x86_64_for_${USER}"
CONTAINER_NAME="development-container-for-ros-2-on-m1-2-mac-x86_64_for_${USER}_container"

if [ ! "$(docker image ls -q ${NAME_IMAGE})" ]; then
    if [ ! $# -ne 1 ]; then
        if [ "build" = $1 ]; then
            echo "Image ${NAME_IMAGE} does not exist."
            echo 'Now building image without proxy...'
            docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg SETLOCALE='JP'
            exit 0
        else
            echo "Docker image is not found. Please setup first!"
            exit 0
        fi
    elif [ ! $# -ne 2 ]; then
        if [ "build" = $1 ]; then
            if [ "US" = $2 ]; then
                echo "Image ${NAME_IMAGE} does not exist."
                echo 'Now building image without proxy...'
                docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg LOCALE='US'
                exit 0
            else
                echo "Image ${NAME_IMAGE} does not exist."
                echo 'Now building image without proxy...'
                docker build --file=./Dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -u) --build-arg UNAME=$USER --build-arg LOCALE='JP'
                exit 0
            fi
        else
            echo "Docker image is not found. Please setup first!"
            exit 0
        fi
    else
        echo "Docker image is not found. Please setup first!"
        exit 0
    fi
else
    if [ ! $# -ne 1 ]; then
        if [ "build" = $1 ]; then
            echo "Docker image is found. Please select mode!"
            exit 0
        fi
    elif [ ! $# -ne 2 ]; then
        if [ "build" = $1 ]; then
            echo "Docker image is found. Please select mode!"
            exit 0
        fi
    fi
fi

# Commit
if [ ! $# -ne 1 ]; then
    if [ "commit" = $1 ]; then
        docker commit ${CONTAINER_IMAGE} ${NAME_IMAGE}:latest
        CONTAINER_ID=$(docker ps -a -f name=${CONTAINER_IMAGE} --format "{{.ID}}")
        docker rm $CONTAINER_ID -f
        exit 0
    fi
fi

# Stop
if [ ! $# -ne 1 ]; then
    if [ "stop" = $1 ]; then
        CONTAINER_ID=$(docker ps -a -f name=${CONTAINER_IMAGE} --format "{{.ID}}")
        docker stop $CONTAINER_ID
        docker rm $CONTAINER_ID -f
        exit 0
    fi
fi

# Delete
if [ ! $# -ne 1 ]; then
    if [ "delete" = $1 ]; then
        echo 'Now deleting docker container...'
        CONTAINER_ID=$(docker ps -a -f name=${CONTAINER_IMAGE} --format "{{.ID}}")
        docker stop $CONTAINER_ID
        docker rm $CONTAINER_ID -f
        docker image rm ${NAME_IMAGE}
        exit 0
    fi
fi

DOCKER_OPT=""
DOCKER_WORK_DIR="/home/${USER}"
MAC_WORK_DIR="/Users/${USER}"

## For XWindow
DOCKER_OPT="${DOCKER_OPT} \
                --volume=/Users/${USER}:/home/${USER}/host_home:rw \
                --shm-size=4gb \
                --env=TERM=xterm-256color \
                -w ${DOCKER_WORK_DIR} \
                -u ${USER} \
                --ipc=host \
                --hostname Docker-$(hostname) \
                --add-host Docker-$(hostname):127.0.1.1 \
                -p 3389:3389 \
                -p 8765:8765 \
                -p 9090:9090 \
                -e PASSWD=${USER}"

## Allow X11 Connection
CONTAINER_ID=$(docker ps -a -f name=${CONTAINER_IMAGE} --format "{{.ID}}")
if [ ! "$CONTAINER_ID" ]; then
    if [ ! $# -ne 1 ]; then
        if [ "xrdp" = $1 ]; then
            echo "Remote Desktop Mode"
            docker run ${DOCKER_OPT} \
                --name=${CONTAINER_NAME} \
                --entrypoint docker-entrypoint.sh \
                ${NAME_IMAGE}:latest
        else
            docker run ${DOCKER_OPT} \
                --name=${CONTAINER_NAME} \
                --volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
                -it \
                --entrypoint /bin/bash \
                ${NAME_IMAGE}:latest
        fi
    else
        docker run ${DOCKER_OPT} \
            --name=${CONTAINER_NAME} \
            --volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
            -it \
            --entrypoint /bin/bash \
            ${NAME_IMAGE}:latest
    fi
else
    if [ ! $# -ne 1 ]; then
        if [ "xrdp" = $1 ]; then
            echo "Remote Desktop Mode"
            docker run ${DOCKER_OPT} \
                --name=${CONTAINER_NAME} \
                --volume=$MAC_WORK_DIR/.Xauthority:$DOCKER_WORK_DIR/.Xauthority:rw \
                --entrypoint docker-entrypoint.sh \
                ${NAME_IMAGE}:latest
        else
            docker start $CONTAINER_ID
            docker exec -it $CONTAINER_ID /bin/bash
        fi
    else
        docker start $CONTAINER_ID
        docker exec -it $CONTAINER_ID /bin/bash
    fi
fi
