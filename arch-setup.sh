#!/usr/bin/env bash

root_part=""
efi_part=""
swap_part=""
package_list="$(cat package-list.txt)"

user_grp=""
user_name=""

cryptsetup -y -v luksFormat --type luks2 "$root_part" cryptroot
cryptsetup open "$root_part" cryptroot
mkfs.ext4 /dev/mapper/cryptroot

mkswap "$swap_part"
swapon "$swap_part"
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "$efi_part" /mntboot

pacstrap /mnt base

genfstab -U /mnt >> /mnt/etc/fstab

cp -av systemd-boot /mnt/tmp/

arch-chroot /mnt
pacman -S --noconfirm "$package_list"

bootctl install
cp /tmp/systemd-boot/loader.conf /boot/loader/loader.conf
cp /tmp/systemd-boot/arch.conf /boot/loader/entries/arch.conf
sed -i "s/SWAPPART/$swap_part/" /boot/load/entries/arch.conf


sed -i 's/#en_US-UTF-8/en_US-UTF-8/' /etc/locale.gen
locale-gen
echo "en_US-UTF-8" > /etc/locale.conf

groupadd "$user_grp"
useradd -m -g "$user_grp" -G wheel -s /bin/bash "$user_name"
passwd "$user_name"

exit

echo "Don't forget to set PART-ID of your root disk in /boot/loader/entries/arch.conf!"
echo "Afterwards, you can reboot"
