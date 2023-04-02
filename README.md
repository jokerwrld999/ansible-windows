# Windows Automation With Ansible

This project aims to simplify the installation and configuration of essential software required for web and software development. Please refer to the instructions below to provision your operating system and get started with ease.

# Setting up a Windows Host (Managed node)

1. Run PowerShell As Administrator

2. Launch Command To Enable WinRM:

```
irm "https://raw.githubusercontent.com/jokerwrld999/windows-ansible/main/EnableWinRM.ps1" | iex
```

# Setting up a Server (Control node)

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

- Debloat your windows machine
- Install specified software
- Tweak windows and reduce running processes
- Restore User's Configs
- Update windows system
- Get a notification in Telegram once setup is finished


## Issues

Please avoid using this directly on your own machines as it was developed for my specific use-case and may not be suitable for your needs.
