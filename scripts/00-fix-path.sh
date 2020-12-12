#!/bin/sh

# Copy script in /etc/profile.d/ to be loaded at launch
sudo cp scripts/00-home-local-bin.sh.tpl /etc/profile.d/00-home-local-bin.sh
sudo chmod 0644 /etc/profile.d/00-home-local-bin.sh
