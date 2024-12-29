#!/bin/sh

# check if optimus-manager is installed
if ! command -v optimus-manager &> /dev/null
then
    echo "GPU: No"
    exit
else
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ print "GPU",""$1"","%"}'
fi


