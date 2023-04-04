# \#Requires -RunAsAdministrator

$wsl_dir = "$env:userprofile\WSL"
$distro = $args[0]
$custom_user = $args[1]
$passwd = $args[2]
$vault_pass = $args[3]

if (!($custom_user = "")) { $custom_user = "jokerwrld" }
if (!($passwd = "")) { $passwd = $custom_user }
if (!($vault_pass = Read-Host "Vault pass ")) { $vault_pass = "$default_pass" }


if (!(Test-Path -Path "$wsl_dir")) {
    New-Item -Path "$wsl_dir" -ItemType "directory"
}

if ($distro -eq "Arch"){
    if (!(Test-Path -Path "$wsl_dir\Arch.zip") -and !(Test-Path -Path "$wsl_dir\Arch")) {
        Write-Host "####### Downloading Arch Distro....... #######" -f Green
        Invoke-WebRequest -Uri https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip -OutFile $wsl_dir\Arch.zip

        Write-Host "####### Extractiing Arch Distro....... #######" -f Green
        Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch

        Write-Host "####### Remove Temp Files....... #######" -f Green
        Remove-Item -Recurse -Force $wsl_dir\Arch.zip
    }
    else {
        Write-Host "Arch Distro already exists" -f Yellow
    }

    Write-Host "####### Start Arch Distro....... #######" -f Green
    Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe
    Write-Host "####### Arch Pre-Setup And Update....... #######" -f Green
    wsl -d Arch -u root /bin/bash -c "
        pacman -Sy archlinux-keyring --needed --noconfirm;
        pacman -Syu --noconfirm;
        pacman -S ansible git --needed --noconfirm;
    "

    Write-Host "####### Arch Setup Default User....... #######" -f Green
    wsl -d Arch -u root /bin/bash -c "
        echo $vault_pass > /home/$custom_user/.vault_pass;
        echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=$custom_user' > /etc/wsl.conf;
        echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel;
        useradd -m -p $passwd -G wheel -s /bin/bash $custom_user;
    "
    wsl --terminate Arch

    Write-Host "####### Initialize keyring....... #######" -f Green
    wsl -d Arch -u $custom_user /bin/bash -c "
        sudo pacman-key --init;
        sudo pacman-key --populate;
        sudo pacman -Sy archlinux-keyring --needed --noconfirm;
        sudo pacman -Su --needed --noconfirm
    "

    Write-Host "####### Run Ansible Playbook....... #######" -f Green
    wsl -d Arch -u $custom_user /bin/bash -c "ansible-pull -U https://github.com/jokerwrld999/ansible-linux.git"


}
elseif ($distro -eq "Fedora") {
    if (!(Test-Path -Path "$wsl_dir\Fedora.msixbundle") ) {
        Write-Host "####### Downloading Fedora Distro And Cert....... #######" -f Green
        Invoke-WebRequest -Uri https://github.com/VSWSL/Fedora-WSL/releases/download/v37.0.3.0/FedoraWSL-Appx_37.0.3.0_x64.msixbundle -OutFile $wsl_dir\Fedora.msixbundle
        Invoke-WebRequest -Uri https://github.com/VSWSL/Fedora-WSL/releases/download/v37.0.3.0/FedoraWSL-Appx_37.0.3.0_x64.cer -OutFile $wsl_dir\Fedora.cer

        Write-Host "####### Installing Fedora Distro And Cert....... #######" -f Green
        Import-Certificate -FilePath "$wsl_dir\Fedora.cer" -CertStoreLocation Cert:\LocalMachine\Root
        Add-AppxPackage -Path "$wsl_dir\Fedora.msixbundle"

        Write-Host "####### Remove Temp Files....... #######" -f Green
        Remove-Item -Recurse -Force $wsl_dir\Fedora.msixbundle $wsl_dir\Fedora.cer
    }
    else {
        Write-Host "Fedora Distro already exists" -f Yellow
    }
}
elseif ($distro -eq "Ubuntu" -or $distro -eq "" ) {
    wsl --install ubuntu
}
else {
    Write-Host "No shuch distro in the list" -f Yellow
}
