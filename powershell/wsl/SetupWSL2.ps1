# \#Requires -RunAsAdministrator

$distro = $args[0]
$wsl_dir = "$env:userprofile\AppData\Local\Packages\"

if ($custom_user -eq $null) {
    if ($args[1] -ne $null) {
        $custom_user = $args[1]
    } else {
        $custom_user = "jokerwrld"
    }
}
if ($passwd -eq $null) {
    if ($args[2] -ne $null) {
        $passwd = $args[2]
    } else {
        $passwd = $custom_user
    }
}
if ($vault_pass -eq $null) {
    if ($args[3] -ne $null) {
        $vault_pass = $args[3]
    } else {
        $vault_pass = Read-Host "Vault pass: "
    }
}

function setupUser($sudo_group) {
    Write-Host "####### Distro is $distro and $sudo_group" -f Red
    wsl -d $distro -u root /bin/bash -c "
        echo '%$sudo_group ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$sudo_group;
        echo -e '[boot]\nsystemd=true\n\n[user]\ndefault=$custom_user' > /etc/wsl.conf;
        useradd -m -p $passwd -G $sudo_group -s /bin/bash $custom_user;
        echo $vault_pass > /home/$custom_user/.vault_pass
    "
    wsl --terminate $distro
}

if ($distro -eq "Arch") {
    if (!(Test-Path -Path "$wsl_dir\Arch.zip") -and !(Test-Path -Path "$wsl_dir\Arch\rootfs.tar.gz")) {
        Write-Host "####### Downloading Arch Distro....... #######" -f Green
        Invoke-WebRequest -Uri https://github.com/yuk7/ArchWSL/releases/download/22.10.16.0/Arch.zip -OutFile $wsl_dir\Arch.zip

        Write-Host "####### Extractiing Arch Distro....... #######" -f Green
        Expand-Archive -Path $wsl_dir\Arch.zip -DestinationPath $wsl_dir\Arch
    }
    else {
        Write-Host "Arch Distro already exists" -f Yellow
    }

    Write-Host "####### Starting Arch Distro....... #######" -f Green
    Start-Process -WindowStyle hidden $wsl_dir\Arch\Arch.exe
    while($true) {
        Write-Host "####### Updating Distro....... #######" -f Green
        wsl -d Arch -e ls
        if($? -eq "true") {
            wsl -d Arch -u root /bin/bash -c "
                rm -rf /var/lib/pacman/db.lck;
                pacman -Sy archlinux-keyring --needed --noconfirm;
                pacman -Syu --noconfirm;
                pacman -S ansible git --needed --noconfirm
            "

            Write-Host "####### Setting Up Default User....... #######" -f Green
            setupUser 'wheel'
            wsl -d Arch -u root /bin/bash -c "usermod -a -G wheel $custom_user"

            Write-Host "####### Initializing keyring....... #######" -f Green
            wsl -d Arch -u $custom_user /bin/bash -c "
                sudo pacman-key --init;
                sudo pacman-key --populate;
                sudo pacman -Sy archlinux-keyring --needed --noconfirm;
                sudo pacman -Su --needed --noconfirm
            "

            break
        }
        else {
            Write-Host "####### Registring Arch Distro....... #######" -f Blue
            Start-Sleep -s 10
        }
    }

    Write-Host "####### Remove Temp Files....... #######" -f Green
    Remove-Item -Recurse -Force $wsl_dir\Arch.zip
}
elseif ($distro -eq "Fedora") {
    if (!(Test-Path -Path "$wsl_dir\Fedora.msixbundle") ) {
        Write-Host "####### Downloading Fedora Distro And Cert....... #######" -f Green
        Invoke-WebRequest -Uri https://github.com/VSWSL/Fedora-WSL/releases/download/v37.0.3.0/FedoraWSL-Appx_37.0.3.0_x64.msixbundle -OutFile $wsl_dir\Fedora.msixbundle
        Invoke-WebRequest -Uri https://github.com/VSWSL/Fedora-WSL/releases/download/v37.0.3.0/FedoraWSL-Appx_37.0.3.0_x64.cer -OutFile $wsl_dir\Fedora.cer

        Write-Host "####### Installing Distro....... #######" -f Green
        Import-Certificate -FilePath "$wsl_dir\Fedora.cer" -CertStoreLocation Cert:\LocalMachine\Root
        Add-AppxPackage -Path "$wsl_dir\Fedora.msixbundle"

        Write-Host "####### Updating Distro....... #######" -f Green
        wsl -d $distro -u root /bin/bash -c "
            dnf update -y;
            dnf install ansible git -y
        "

        Write-Host "####### Setting Up Default User....... #######" -f Green
        setupUser 'wheel'

        Write-Host "####### Remove Temp Files....... #######" -f Green
        Remove-Item -Recurse -Force $wsl_dir\Fedora.msixbundle $wsl_dir\Fedora.cer
    }
    else {
        Write-Host "Fedora Distro already exists" -f Yellow
    }
}
elseif ($distro -eq "Ubuntu" -or $distro -eq $null ) {
    $distro = "ubuntu"

    Write-Host "####### Installing Ubuntu Distro....... #######" -f Green
    ubuntu install --root

    Write-Host "####### Updating Distro....... #######" -f Green
    wsl -d $distro -u root /bin/bash -c "
        apt update && apt upgrade -y;
        apt install ansible git -y
    "
    Write-Host "####### Setting Up Distro....... #######" -f Green
    setupUser 'sudo'

}
else {
    Write-Host "No shuch distro in the list" -f Yellow
}

Write-Host "####### Runing Ansible Playbook on $distro....... #######" -f Green
wsl -d $distro -u $custom_user /bin/bash -c "ansible-pull -U https://github.com/jokerwrld999/ansible-linux.git"