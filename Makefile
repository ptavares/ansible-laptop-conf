
# ######################################################################################
# # 						Ansible Laptop conf Makefile
# ######################################################################################

# # Default shell to use
SHELL=/bin/bash
# ========================================
# COLORS SETUP
# ========================================
# to see all colors, run
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'
# the first 15 entries are the 8-bit colors

#  Define standard colors
BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
PURPLE       := $(shell tput -Txterm setaf 5)
BLUE         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)

RESET := $(shell tput -Txterm sgr0)

# set target color
TARGET_COLOR := $(BLUE)

# set message
MESSAGE      = @echo "${LIGHTPURPLE}▶${RESET} $1"

# ========================================
# COMMONS VARS
# ========================================
INVENTORY            = inventory
PLAYBOOK_DIR        ?= playbooks
DEFAULT_PLAYBOOK     = init-laptop.yml
REQUIREMENTS_DIR    ?= requirements
DEFAULT_REQUIREMENTS = requirements_ansible.yml

# ========================================
# SETUP VARS
# ========================================

# Current Host
HOSTNAME = $(shell hostname)

# Allows user to specify private hostname in ".inventory file"
PRIVATE_INVENTORY = ".inventory"
ifeq ($(shell test -e $(PRIVATE_INVENTORY) && echo -n yes),yes)
	inventory=$(PRIVATE_INVENTORY)
else
    inventory = $(INVENTORY)
endif

# Add force option to ansible-galaxy command
FORCE ?=
ifeq ($(F), 1)
  force    := "--force"
endif
# Ansible options
ifeq ($(diff), 1)
  opts     := $(opts) --diff
endif

ifneq ("$(limit)", "")
  opts     := $(opts) --limit="$(limit)"
endif
ifneq ("$(tag)", "")
  opts     := $(opts) --tag="$(tag)"
endif

# ========================================
# COMMANDS
# ========================================
# Main Ansible Playbook Command (prompts for password)
ANSIBLE=ansible-playbook $(PLAYBOOK_DIR)/$(playbook) -v -i $(inventory) $(opts) --ask-become-pass -e '{"ansible_user": "$(shell whoami)"}'
# Ansible Galaxy Command
GALAXY=ansible-galaxy install -r $(REQUIREMENTS_DIR)/$(requirements) $(force)

# ========================================
# TARGETS
# ========================================
# $(warning DEFAULT_PLAYBOOK is $(DEFAULT_PLAYBOOK))

.PHONY: no_targets__ info help build deploy doc
	no_targets__:


.DEFAULT_GOAL := help

# =================================================
## ,.-~*´¨¯¨`*·~-.¸-( Bootstrap )-,.-~*´¨¯¨`*·~-.¸
# =================================================

.bootstrap-before-install:
	$(call MESSAGE,  Apt Dependencies (removes apt ansible))
	bash scripts/01-init.sh


.bootstrap-install:
	$(call MESSAGE, Python3 Dependencies (install python3 ansible))
	bash scripts/02-init-python.sh


.bootstrap-before-script:
	@$(call MESSAGE, Ensure "$$HOME/.local/bin" is part of PATH)
	bash scripts/00-fix-path.sh

	@$(call MESSAGE, Source folder (to ensure initial setup loads this file))
	@. /etc/profile


.PHONY: bootstrap
## Installs dependencies needed to run ansible playbooks
bootstrap: .bootstrap-before-script .bootstrap-before-install .bootstrap-install

.PHONY: bootstrap-check
## Check that PATH and requirements are correct
bootstrap-check: .bootstrap-before-script
	$(call MESSAGE, Check that PATH and requirements are correct)
	ansible --version | grep "python version"
	python3 -m pip list --format=columns | grep psutil


# =================================================
## ,.-~*´¨¯¨`*·~-.¸-( Ansible )-,.-~*´¨¯¨`*·~-.¸
# =================================================

.PHONY: inventory
## Display the inventory as seen from Ansible
## Usage            : make inventory [env=hosts]
## Available args   :
##   - env          : Name of the inventory you want to use, default set to $(INVENTORY)
##
inventory: env ?= $(inventory)
inventory:
	@ansible-inventory --graph -i $(env) $(opts)

.PHONY: list
## List hosts inventory
## Usage            : make list [group=all] [env=hosts]
## Available args   :
##   - env          : Name of the inventory you want to use, default set to $(INVENTORY)
##   - group        : Group to show, default set to all
##
list: env  ?= $(inventory)
list: group ?= all
list:
	@ansible --inventory-file="$(env)" $(group) --list-hosts

.PHONY: list-tasks
## List playbook tasks and tags
## Usage             : make list-tasks [playbook=setup]
## Available args    :
##   - playbook      : specify your playbook in $(PLAYBOOK_DIR), default set to $(DEFAULT_PLAYBOOK)
##   - PLAYBOOK_DIR  : specify your playbook directory
##
list-tasks: playbook ?= $(DEFAULT_PLAYBOOK)
list-tasks:
	@ansible-playbook $(PLAYBOOK_DIR)/$(playbook) -K --list-tasks

.PHONY: install-roles
## Install ansible role dependencies
## Usage            : make install-roles [requirements=requirement.yml] [F=1]
## Available args   :
##   - requirements : specify custom requirements file, default set to $(REQUIREMENTS_DIR)/$(DEFAULT_REQUIREMENTS)
##   - F            : set F=1 to force download if role already exist
##
install-roles: requirements ?= $(DEFAULT_REQUIREMENTS)
install-roles:
	@$(GALAXY)

.PHONY: dry-run
## Run playbook in dry run mode
## Usage          :  make dry-run [playbook=setup] [env=hosts] [tag=<ansible tag>] [limit=<ansible host limit>] [diff=1]
## Available args :
##   - playbook        : specify your playbook in $(PLAYBOOK_DIR), default set to $(DEFAULT_PLAYBOOK)
##   - PLAYBOOK_DIR    : specify your playbook directory
##   - env             : Name of the inventory you want to use, default set to $(INVENTORY)
##   - tag             : Specify a list of tags for your ansible run, default <none>
##   - limit           : Limit the command to a subset of hosts with ansible's limit argument, default <none>
##   - diff            : set diff=1 to run command with '--diff' option
##
dry-run: playbook ?= $(DEFAULT_PLAYBOOK)
dry-run: install-roles
dry-run:
	@$(ANSIBLE) --check

.PHONY: run-install
## Run install playbook
## Usage          :  make run-install [playbook=setup] [env=hosts] [tag=<ansible tag>] [limit=<ansible host limit>] [diff=1]
## Available args :
##   - playbook        : specify your playbook in $(PLAYBOOK_DIR), default set to $(DEFAULT_PLAYBOOK)
##   - PLAYBOOK_DIR    : specify your playbook directory
##   - env             : Name of the inventory you want to use, default set to $(INVENTORY)
##   - tag             : Specify a list of tags for your ansible run, default <none>
##   - limit           : Limit the command to a subset of hosts with ansible's limit argument, default <none>
##   - diff            : set diff=1 to run command with '--diff' option
##
run-install: playbook ?= $(DEFAULT_PLAYBOOK)
run-install: install-roles
run-install:
	@$(ANSIBLE)

# =================================================
## ,.-~*´¨¯¨`*·~-.¸-( Updates )-,.-~*´¨¯¨`*·~-.¸
# =================================================

.PHONY: update-system
## Run update system from $(DEFAULT_PLAYBOOK)
## Usage         : make update-system
##
update-system: playbook ?= $(DEFAULT_PLAYBOOK)
update-system: tags ?= "manage-system-update, manage-system-clean"
update-system: install-roles
update-system:
	@$(ANSIBLE)

.PHONY: update-docker
## Run update docker from $(DEFAULT_PLAYBOOK)
## Usage         : make update-docker
##
update-docker: playbook ?= $(DEFAULT_PLAYBOOK)
update-docker: tags ?= "docker"
update-docker: install-roles
update-docker:
	@$(ANSIBLE)

.PHONY: update-docker-compose
## Run update docker-compose from $(DEFAULT_PLAYBOOK)
## Usage         : make update-docker-compose
##
update-docker-compose: playbook ?= $(DEFAULT_PLAYBOOK)
update-docker-compose: tags ?= "docker-install-compose"
update-docker-compose: install-roles
update-docker-compose:
	@$(ANSIBLE)

.PHONY: update-kubectl
## Run update kubectl from $(DEFAULT_PLAYBOOK)
## Usage         : make update-kubectl
##
update-kubectl: playbook ?= $(DEFAULT_PLAYBOOK)
update-kubectl: tags ?= "kubectl"
update-kubectl: install-roles
update-kubectl:
	@$(ANSIBLE)

.PHONY: update-zsh-config
## Run update zsh-config from $(DEFAULT_PLAYBOOK)
## Usage         : make update-zsh-config
##
update-zsh-config: playbook ?= $(DEFAULT_PLAYBOOK)
update-zsh-config: tags ?= "zsh-install-compose"
update-zsh-config: install-roles
update-zsh-config:
	@$(ANSIBLE)

# =================================================
## ,.-~*´¨¯¨`*·~-.¸-( Commons )-,.-~*´¨¯¨`*·~-.¸
# =================================================

.PHONY: all
## Does most eveything with Ansible and Make targets
## Call bellow targets : bootstrap bootstrap-check run non-ansible
## You can specify all args available from those target
all: bootstrap bootstrap-check run-install non-ansible

# =================================================
## ,.-~*´¨¯¨`*·~-.¸-( Help )-,.-~*´¨¯¨`*·~-.¸
# =================================================

.PHONY: lint
## Lint all files
lint:
	bash scripts/03-lint.sh


.PHONY: test-with-docker
## Start a Docker container with volume; so you can change the code directly
test-with-docker:
	docker container run --rm -it -v ${PWD}:/home/ubuntu/ansible-laptop-conf tavarespatrick/ubuntu-ansible:latest bash

## Show this help
.PHONY: help
help:
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# adds anything that has a double # comment to the phony help list
	@echo "${LIGHTPURPLE}-----------------------------------------------------------------------------------------------------"
	@echo '    \              _)  |     |             |                 |                                     _| '
	@echo '   _ \     \  (_-<  |   _ \  |   -_) ____| |      _` |  _ \   _|   _ \  _ \ ____| _|   _ \    \    _| '
	@echo ' _/  _\ _| _| ___/ _| _.__/ _| \___|      ____| \__,_| .__/ \__| \___/ .__/     \__| \___/ _| _| _|   '
	@echo '                                                     _|              _|                              '
	@echo "-----------------------------------------------------------------------------------------------------${RESET}"
	@echo "${YELLOW}Usage : ${RESET}"
	@printf "\tmake [target] [arg1=val1] [arg2=val2]...\n";

	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "${BLUE}%-20s${RESET}\t %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "${BLUE}%-20s${RESET}\t %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n\t\t\t "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n\t${LIGHTPURPLE}"helpMessage"${RESET}\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)

	@echo ""
	@echo "${YELLOW}With default variables:"
	@echo "-----------------------${RESET}"
	$(call MESSAGE, REQUIREMENTS_DIR     = $(REQUIREMENTS_DIR))
	$(call MESSAGE, DEFAULT_REQUIREMENTS = $(DEFAULT_REQUIREMENTS))
	$(call MESSAGE, PLAYBOOK_DIR         = $(PLAYBOOK_DIR))
	$(call MESSAGE, DEFAULT_PLAYBOOK     = $(DEFAULT_PLAYBOOK))
	@echo ""


# #$(warning DEFAULT_PLAYBOOK is $(DEFAULT_PLAYBOOK))
