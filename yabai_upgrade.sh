#!/bin/zsh

# Stop yabai
yabai --stop-service

# Echoing the current yabai hash
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai

# loading-sa
sudo yabai --load-sa

# Start everything back
yabai --start-service
