#!/usr/bin/env bash

CURRENT_SDK=$(cat ~/.Garmin/ConnectIQ/current-sdk.cfg)
if [ -n "${CURRENT_SDK}" ]; then
    echo "Using current SDK ${CURRENT_SDK}"
    export PATH=${CURRENT_SDK}/bin:$PATH
else
    echo "No .Garmin/ folder or current sdk set, start 'sdkmanager' to download it."
fi

exec "$@"
