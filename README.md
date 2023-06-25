# Windows Automation With Ansible

This project aims to simplify the installation and configuration of essential software required for web and software development. Please refer to the instructions below to provision your operating system and get started with ease.

# Setting up a Machine

## 1. To Enable WinRM:

```
irm "https://raw.githubusercontent.com/jokerwrld999/ansible-windows/main/powershell/winrm/EnableWinRM.ps1" | iex
```

## 1.1 To Disable WinRM:

```
irm "https://raw.githubusercontent.com/jokerwrld999/ansible-windows/main/powershell/winrm/DisableWinRM.ps1" | iex
```

## 2. To Set Up WSL2:

```
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/wsl/SetupWSL.ps1" | iex
```

## 3. To Set Up OpenSSH:

```
irm "https://raw.githubusercontent.com/jokerwrld999/ansible-windows/main/powershell/openssh/SetupOpenSSH.ps1" | iex
```

# Variables List

* Modify the variables in inventory/hosts.ini

```
[windows:vars]
ansible_user=<ansible_user>
ansible_password=<ansible_password>
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore

[windows]
#IP-address
```

* Modify the variables in roles/base/vars/main.yml

```
---

# Software Configuration
install_desktop_packages: false

# User Configuration
custom_user: jokerwrld
home_dir: 'C:\Users\{{ custom_user }}'
temp_dir: '{{ home_dir }}\AppData\Local\Temp'

# System Configuration
configure_hostname: false
custom_hostname: Server

change_power_plan: false
# high_performance, balanced, power_saver
power_plan: "high_performance"

configure_start_menu: false
configure_taskbar: false
remove_desktop_icons: false
remote_desktop_enabled: false

telegram_chat_id:
telegram_token:
```


* Ensure that Ansible is installed on your Linux or WSL machine and execute the following command:

```
ansible-playbook local.yml
```

## Overview

- Update windows system
- Set up Windows Subsystem Linux(WSL)
- Set up Ansible automation
- Set up OpenSSH
- Debloat your windows machine
- Install specified software
- Tweak windows and reduce running processes
- Restore user's configs
- Get a notification in Telegram once setup is finished

## Issues

Please avoid using this directly on your own machines as it was developed for my specific use-case and may not be suitable for your needs.
