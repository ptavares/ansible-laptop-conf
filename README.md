# Laptop configuration with ansible

This project is used to setup and configure my laptop :computer:

## All-in-One

```bash
 | bash
```

## Manually

### Prerequires

You have to install git and make :

```bash
sudo apt install git make
```

### Installation

- Clone this repository

```bash
git clone https://github.com/ptavares/ansible-laptop-conf.git && cd ansible-laptop-conf
```

- Install laptop requirements

```bash
make bootstrap
```

- Reload profile to update user path

```bash
source /etc/profile
```

- Check laptop requirements

```bash
make bootstrap-check
```

- Install all

```bash
make run-install
```

## Ansible Roles

| Role| Description|
| - | - |
| | **General** |
| [manage_system](https://github.com/ptavares/ansible-role-manage-system) | Update system, install a lot of usefull packages (curl, htop, zip,....), remove unused packages and install specific deb files. See [configuration task file](group_vars/all/system.yml) for more information |
| fonts | Download [nerd-font](https://github.com/ryanoasis/nerd-fonts.git) from git |
| tmux | Install tmux and tmuxinator with some plugins |
| vim | Install vim with some plugins and install [molokai](https://github.com/tomasr/molokai.git) theme | 
