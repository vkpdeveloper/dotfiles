#!/bin/bash

device="$1"

if [[ "$device" = "laptop" ]] then
    cp $HOME/.config/i3/config_with_laptop $HOME/.config/i3/config
else if [[ "$device" = "desktop" ]] then
    cp $HOME/.config/i3/config_only_desktop $HOME/.config/i3/config
else
    echo "Usage: $0 <laptop|desktop>"
fi
fi

i3-msg reload
