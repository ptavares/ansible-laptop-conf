#!/bin/bash -e
SCRIPT=`realpath -s $0`
SCRIPT_PATH=`dirname $SCRIPT`
CURRENT_DIR=`pwd`

echo $SCRIPT_PATH

function log {
    echo `$DATE`" === $1"
}

function callplaybook {
    cd ${SCRIPT_PATH}
    ansible-playbook playbooks/init-laptop.yml --tags "$1" ${*:2}
    cd ${CURRENT_DIR}
}

case $1 in
    system)
        log "update system"
        callplaybook "manage-system-update, manage-system-clean" ${*:2}
        ;;
    zshconfig)
        log "update zsh config"
        callplaybook "zsh-install-conf" ${*:2} 
        ;;
    dockercompose)
        log "update docker-compose"
        callplaybook "docker-install-compose" ${*:2}
        ;;
    terraform)
        log "update terrafrom"
        callplaybook "terraform" ${*:2}
        ;;
    terragrunt)
        log "update terragrunt"
        callplaybook "terragrunt" ${*:2}
        ;;
    kubectl)
        log "update kubectl"
        callplaybook "kubectl" ${*:2}
        ;;
    docker)
        log "update docker"
        callplaybook "docker" ${*:2}
        ;;
    vsc)
        log "update visualstudiocode"
        callplaybook "vsc" ${*:2}
        ;;
    shellextension)
        log "update shell-extension"
        callplaybook "shell-extension" ${*:2}
        ;;
    *)
        echo "usage ${0} [system|zshconfig|dockercompose|terraform|terragrunt|kubectl|docker|vsc|shellextension]"
        exit 1
        ;;
esac