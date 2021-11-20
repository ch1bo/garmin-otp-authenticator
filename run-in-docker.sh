#!/usr/bin/env bash
xhost +local:

MAP_UID=${UID:-`id -u`}
MAP_GID=${GID:-`id -g`}

docker run -it --rm \
    -e DISPLAY=unix$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $PWD/.Garmin:/home/developer/.Garmin \
    -v $PWD:$PWD \
    -w $PWD \
    -u $MAP_UID:$MAP_GID \
    --privileged \
    connectiq:latest "$@"
