#!/bin/bash -e

# ########################################################
# Variables
# ########################################################
DIR=tools
GIT_REPO=ansible-laptop-conf
GIT_URL=https://github.com/ptavares/"${GIT_REPO}".git

# ########################################################
# Functions
# ########################################################

## -------------------------------------------------------
## log function
## -------------------------------------------------------
function log {
    echo `$DATE`" === $1"
}

function minimalPackage() {
    log "Install minimum Dependencies Required to run this script"
    sudo apt-get update
    sudo apt install -y git make
}

function checkoutRepo() {    
    log " -> Create ${DIR} if not exist"
    cd ~ || exit
    mkdir -p "${DIR}"
    cd "${DIR}" || exit
    if [ ! -d "${GIT_REPO}" ] ; then
        log "Checkout ansible-laptop-conf repository"
        git clone "${GIT_URL}" "${GIT_REPO}"
    else
        log "Update ansible-laptop-conf repository"
        cd "${GIT_REPO}"
        git reset --hard origin/master
    fi
}

function runBootstrap() {
    cd ~/"${DIR}"/"${GIT_REPO}"
    log "Initial Bootstrap to Setup Machine..."
    make bootstrap

    log "Reload profile to update user path..."
    source /etc/profile

    log "Check BootStrap install..."
    make bootstrap-check
}

function runInstall() {
    cd ~/"${DIR}"/"${GIT_REPO}"
    log "Install all with ansible ..."
    make run-install
}


# ########################################################
# Main
# ########################################################
minimalPackage
checkoutRepo
runBootstrap
runInstall

log "Don't forget to install tmux plugins on first tmux's session with 'prefix + I'"
