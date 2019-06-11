#!/usr/bin/env bash
set -eu

# START OF CONFIGURATION
root_part=""
efi_part=""
swap_part=""
package_list="$(cat package-list.txt)"

user_grp=""
user_name=""

hostname=""
# END OF CONFIGURATION

echo "Starting with cryptsetup..."
cryptsetup -y -v luksFormat --type luks2 "$root_part"
cryptsetup open "$root_part" cryptroot

echo "Formatting encrypted disk..."
mkfs.ext4 /dev/mapper/cryptroot

echo "Activating swap..."
mkswap "$swap_part"
swapon "$swap_part"

echo "Mounting disk to /mnt..."
mount /dev/mapper/cryptroot /mnt

echo "Mounting EFI partition to /mnt/boot..."
mkdir /mnt/boot
mount "$efi_part" /mnt/boot

echo "Running pacstrap..."
pacstrap /mnt base

echo "Generating /etc/fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

cp -av systemd-boot /mnt/root/

echo "Chrooting into /mnt..."
arch-chroot /mnt

echo "Installing defined packages..."
# no quotes around $package_list, otherwise it won't work
# shellcheck disable=SC2086
pacman -S --noconfirm $package_list

echo "Installing systemd-boot..."
bootctl install

echo "Configuring systemd-boot..."
cp /root/systemd-boot/loader.conf /boot/loader/loader.conf
cp /root/systemd-boot/arch.conf /boot/loader/entries/arch.conf

echo "Configuring swap partition for hibernation..."
trimmed_swap_part="$(awk 'FS = "/" {print NF}' )"
sed -i "s/SWAPPART/$trimmed_swap_part/" /boot/load/entries/arch.conf

echo "Configuring cryptsetup for systemd-bood..."
# 'ls' might not be the best option here, using it for "now"
# shellcheck disable=SC2010
crypt_disk_uuid="$(ls -l /dev/disk/by-uuid/ | grep "$root_part" | cut -d ' ' -f 9)"
sed -i "s/CRYPTDISKUUID/$crypt_disk_uuid/" /boot/load/entries/arch.conf


echo "Configuring locale settings..."
sed -i 's/#en_US-UTF-8/en_US-UTF-8/' /etc/locale.gen
locale-gen
echo "en_US-UTF-8" > /etc/locale.conf

echo "Adding group for user..."
groupadd "$user_grp"
echo "Adding user..."
useradd -m -g "$user_grp" -G wheel -s /bin/bash "$user_name"
echo "Setting password for user..."
passwd "$user_name"

echo "Configuring mkinitcpio..."
sed -i 's/ block / encrypt block /' /etc/mkinitcpio.conf

echo "Generating new CPIO image..."
mkinitcpio -p linux

echo "Setting hostname..."
echo "$hostname" > /etc/hostname

exit

echo "Reboot and hail satan"
