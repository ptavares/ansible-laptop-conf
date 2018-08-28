#!/bin/bash -e
SCRIPT=`realpath -s $0`
SCRIPT_PATH=`dirname $SCRIPT`
CURRENT_DIR=`pwd`

echo $SCRIPT_PATH

function log {
    echo `$DATE`" === $1"
}

function callPlaybook {
    cd ${SCRIPT_PATH}
    ansible-playbook playbooks/init-laptop.yml --tags "$1"
    cd ${CURRENT_DIR}
}

case $1 in
    update)
        log "Update system"
        callPlaybook "manage-system-update, manage-system-clean"
        ;;
    zshConfig)
        log "Update zsh config"
        callPlaybook "zsh-install-conf"
        ;;
    updateDockerCompose)
        log "Update docker-compose"
        callPlaybook "docker-install-compose"
        ;;
    *)
        echo "usage ${0} [update|zshConfig|updateDockerCompose]"
        exit 1
        ;;
esac