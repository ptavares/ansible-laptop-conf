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
    ansible-playbook playbooks/init-laptop.yml --tags "$1" ${*:2}
    cd ${CURRENT_DIR}
}

case $1 in
    system)
        log "Update system"
        callPlaybook "manage-system-update, manage-system-clean" ${*:2}
        ;;
    zshConfig)
        log "Update zsh config"
        callPlaybook "zsh-install-conf" ${*:2} 
        ;;
    updateDockerCompose)
        log "Update docker-compose"
        callPlaybook "docker-install-compose" ${*:2}
        ;;
    updateTerraform)
        log "Update terrafrom"
        callPlaybook "terraform" ${*:2}
        ;;
    updateTerragrunt)
        log "Update terragrunt"
        callPlaybook "terragrunt" ${*:2}
        ;;
    *)
        echo "usage ${0} [system|zshConfig|updateDockerCompose|updateTerraform|updateTerragrunt]"
        exit 1
        ;;
esac