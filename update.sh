#!/bin/bash -e

function log {
    echo `$DATE`" === $1"
}

log "Update system"
ansible-playbook update-laptop.yml --tags "system, manage-system-update, manage-system-clean"

