#!/bin/bash -e

function log {
    echo `$DATE`" === $1"
}

function installAnsible {
    log "Install python-pip..."
    # install python-pip for last ansible version
    sudo apt install python3-pip
    log "Install last ansible..."
    sudo pip3 install ansible
}

function installReqs {
   log "Install requirements"
   ansible-galaxy install -r requirements/requirements.yml
}

#installAnsible
installReqs
log "Init system..."
#ansible-playbook playbooks/init-laptop.yml --tags "system" -v
log "Init tools..."
ansible-playbook playbooks/init-laptop.yml --tags "tools" -v
log "Don't forget to install tmux plugins on first tmux's session with 'prefix + I'"
