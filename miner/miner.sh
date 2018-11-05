#!/bin/bash

# This script is compatible with Mac and Linux
SCRIPT_PATH=$(dirname "$0")
NUM_CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    MB_MEMORY=$(cat /proc/meminfo | grep MemTotal | awk '{mb =int($2 /1024); print mb}')
elif [[ "$OSTYPE" == "darwin"* ]]; then
    MB_MEMORY=$(sysctl hw.memsize | awk '{mb =int($2/1024/1024); print mb}')
else
    node "$SCRIPT_PATH/index.js" "$@"
    exit
fi

UV_THREADPOOL_SIZE=$NUM_CORES NODE_OPTIONS="--max_old_space_size=$MB_MEMORY" node "$SCRIPT_PATH/index.js"  "$@"