#!/bin/sh

# First remove ansible if already installed and update system
sudo apt remove -y ansible
sudo apt -y autoremove
sudo apt update

# Install Python3 & Pip3
sudo apt install -y software-properties-common apt-utils
sudo apt install -y python3-setuptools python3-apt python3-pip

# Install Linter
sudo apt install -y yamllint
sudo apt install -y shellcheck
