#!/usr/bin/env bash

source "./src/_global_vars.sh"
source "./src/_helpers.sh"

source "./src/prompt/01-start.sh"
source "./src/prompt/02-timezone.sh"
source "./src/prompt/03-kernel.sh"
source "./src/prompt/04-user.sh"
source "./src/prompt/05-password.sh"
source "./src/prompt/06-hostname.sh"
source "./src/prompt/07-efi_partition.sh"
source "./src/prompt/08-root_partition.sh"
source "./src/prompt/09-swap.sh"
source "./src/prompt/10-extra_disk.sh"
source "./src/prompt/11-bootloader.sh"
source "./src/prompt/summary.sh"

source "./src/00-prep.sh"
source "./src/01-package.sh"
source "./src/02-locale.sh"
source "./src/03-network.sh"
source "./src/04-adduser.sh"
source "./src/05-bootloader.sh"

source "./src/settings/swap.sh"
source "./src/settings/hibernation.sh"
source "./src/settings/package_config.sh"
source "./src/settings/powerbutton.sh"
source "./src/settings/extra_disk.sh"
source "./src/settings/plymouth.sh"
source "./src/settings/ssh.sh"

set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

start(){
    prep
    package
    locale
    network
    adduser
    bootloader
}

settings(){
    setting_swap
    setting_hibernation
    # powerbutton
    setting_package_config
    setting_extra_disk
    setting_plymouth
    setting_ssh
}

end(){
    if [[ "$BOOTLOADER" == "1" ]]; then
        arch-chroot $MOUNT_POINT grub-mkconfig -o /boot/grub/grub.cfg
    fi
    arch-chroot $MOUNT_POINT mkinitcpio -P
    genfstab -t UUID $MOUNT_POINT >>$MOUNT_POINT/etc/fstab
}

start_prompt
timezone_prompt
kernel_prompt
user_prompt
password_prompt
hostname_prompt
efi_partition_prompt
root_partition_prompt
extradisk_prompt
swap_prompt
bootloader_prompt
print_summary

if [[ ! "$PROCEED" =~ [Nn] ]]; then
    start
    settings
    end

    clear
    print_color $GREEN "Install success\n"
else
    clear
    print_color $YELLOW "Bye\n"
fi

