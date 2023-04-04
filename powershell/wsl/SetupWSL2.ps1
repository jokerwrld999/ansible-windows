# \#Requires -RunAsAdministrator

$wsl_dir = "$env:userprofile\WSL"
$custom_user = "jokerwrld"
$passwd = '1234'
if (!(Test-Path -Path "$wsl_dir")) {
    New-Item -Path "$wsl_dir" -ItemType "directory"
}

$distro = "$args"
if ($distro -eq "arch"){
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
    wsl -d Arch -u root -e pacman -Sy archlinux-keyring --noconfirm
    wsl -d Arch -u root -e pacman -Syu --noconfirm
    wsl -d Arch -u root -e pacman -S ansible --needed --noconfirm
    wsl -d Arch -u root /bin/bash -c "echo $custom_user >> ~/.vault_pass"
    wsl -d Arch -u root /bin/bash -c "echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=$custom_user' > /etc/wsl.conf"
    #wsl --terminate Arch

    Write-Host "####### Arch Setup Default User....... #######" -f Green
    wsl -d Arch -u root /bin/bash -c "echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel"
    wsl -d Arch -u root /bin/bash -c "useradd -m -p $passwd -G wheel -s /bin/bash $custom_user"
    wsl -d Arch -u root /bin/bash -c "echo $passwd | passwd $custom_user"
    wsl --terminate Arch
    ansible-pull -U https://github.com/jokerwrld999/ansible-linux.git

}
elseif ($distro -eq "fedora") {
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
elseif ($distro -eq "ubuntu" -or $distro -eq "" ) {
    'We found a ubuntu'
}
else {
    Write-Host "No shuch distro in the list" -f Yellow
}
