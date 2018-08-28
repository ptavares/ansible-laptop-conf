#!/bin/bash -e

function log {
    echo `$DATE`" === $1"
}

function installAnsible {
    log "Install python-pip..."
    # install python-pip for last ansible version
    sudo apt install python-pip
    sudo pip install --upgrade pip
    log "Install last ansible..."
    sudo pip install ansible
}

function installReqs {
   log "Install requirements"
   ansible-galaxy install -r requirements/requirements.yml --force
   stdout_plugin=./plugins/ansible_stdout_compact_logger
   if [ ! -d "$stdout_plugin" ]; then
     git clone https://github.com/octplane/ansible_stdout_compact_logger.git $stdout_plugin
   fi
}

installAnsible
installReqs
log "Init system..."
ansible-playbook playbooks/init-laptop.yml --tags "system"
log "Init tools..."
ansible-playbook playbooks/init-laptop.yml --tags "tools"
log "Don't forget to install tmux plugins on first tmux's session with 'prefix + I'"
