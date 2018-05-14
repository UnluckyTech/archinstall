# archinstall
#This is the full install manually.
#Use this script if your system falls under this Criteria.

#Intel Based CPU
#Nvidia Drivers
#EFI Mode

PART 1 Prepare/Install Base Packages

Check if internet works
- ping -c 3 google.com

Check if EFI mode is available
- efivar -l

Use timedatectl to ensure the system clock is accurate.
- imedatectl set-ntp true

Check to see if timedatectl worked
- timedatectl status

Shows drives available
- lsblk

THIS WIPES ENTIRE DRIVE
- gdisk /dev/sdX (x representing your drive. mine is sda)
- x
- z
- y
- y

 Create boot partition
- cgdisk /dev/sdX
- press any key to continue
    sda1 (boot partition)
    sda2 (our swap partition)
    sda3 (our home partition)
 Create boot partition
    - [New] Press Enter
    - First Sector: Leave this blank ->press Enter
    - Size in sectors: 1024MiB ->press Enter
    - Hex Code: EF00 press Enter
    - Enter new partition name: boot ->press Enter
 Create swap partition
    - [New] Press Enter
    - First Sector: Leave this blank ->press Enter
    - Size in sectors: 8GiB ->press Enter
    - Hex Code: 8200 ->press Enter
    - Enter new partition name: swap ->press Enter
 Create root with /home inside
    - [New] Press Enter
    - First Sector: Leave this blank ->press Enter
    - Si in sectors: Leave this blank ->press Enter
    -Hde: Leave this blank ->press Enter 
    • Enter new partition name: root ->press Enter
Let linux know the file system for our partitions. For EFI with GPT, boot needs to be Fat32. For swap we simply use mkswap. The rest are default ext4 file systems:
    • mkfs.fat -F32 /dev/sda1
    • mkswap /dev/sda2
    • swapon /dev/sda2
    • mkfs.ext4 /dev/sda3
			PART 2: INSTALL ARCH AND MAKE IT BOOT
Mount Partitions
    • mount /dev/sda3 /mnt
    • mkdir /mnt/boot
    • mkdir /mnt/home
    • mount /dev/sda1 /mnt/boot
- Setting up our Arch repository mirror list
Make a backup
    • cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
Uncomment every mirror
    • sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
Check the top 6 mirrors you have the best connection to
    • rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
Install Arch base files
    • pacstrap -i /mnt base base-devel
Generate fstab file
    • genfstab -U -p /mnt >> /mnt/etc/fstab
Check fstab
    • nano /mnt/etc/fstab

Part 2 Configure Arch Linux

Change root into the system
    • arch-chroot /mnt
    • mkdir /boot/efi
Create locale file
    • nano /etc/locale.gen
    • (uncoment) en_US.UTF-8
    • locale-gen
Set language
    • echo LANG=en_US.UTF-8 > /etc/locale.conf
    • export LANG=en_US.UTF-8
Time
    • ls /usr/share/zoneinfo/
    • ln -s /usr/share/zoneinfo/America/New_York > /etc/localtime
Hardware Clock
    • hwclock --systohc --utc
Hostname
    • echo UnluckyZ170 > /etc/hostname
Enable TRIM service
    • systemctl enable fstrim.timer
Enable multilib repository
    • nano /etc/pacman.conf
Un-comment this
    • [multilib]
    • Include = /etc/pacman.d/mirrorlist
Also add these lines at the bottom
    • [archlinuxfr]
    • SigLevel = Never
    • Server = http://repo.archlinux.fr/$arch
Save and update pacman
    • pacman -Sy
Set password for root
    • passwd
Add the default user
    • useradd -m -g users -G wheel,storage,power -s /bin/bash unluckytech
    • passwd unluckytech
Setting up sudoers
    • EDITOR=nano visudo
un-comment
    • %wheel ALL=(ALL) ALL
At the bottom add this line and save
    • Defaults rootpw
Make it easier to auto-complete and some other stuff hehe
    • pacman -S bash-completion nvidia-dkms linux-headers intel-ucode libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings
Check if EFI variables are mounted
    • mount -t efivarfs efivarfs /sys/firmware/efi/efivars
Set nvidia drm kernal modules
    • sudo nano /etc/mkinitcpio.conf
Find MODULES=
    • MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
Make a pacman hook that automatically adds nvidia
    • sudo nano /etc/pacman.d/hooks/nvidia.hook
    • [Trigger]
    • Operation=Install
    • Operation=Upgrade
    • Operation=Remove
    • Type=Package
    • Target=nvidia
    • 
    • [Action]
    • Depends=mkinitcpio
    • When=PostTransaction
    • Exec=/usr/bin/mkinitcpio -P
Now time for the bootloader GRUB (GOOD LUCK SOLDIER)
    • pacman -S grub efibootmgr
    • mount /dev/sda1 /boot/efi
    • grub-install /dev/sda
    • grub-mkconfig -o /boot/grub/grub.cfg

Now for the display stuff
    • sudo pacman -S mesa xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock xterm
Reboot into Arch Linux
    • exit
    • reboot

Check to see if X runs
    • startx
Add Desktop Manager
    • sudo pacman -S sddm gnome gnome-extra NetworkManager
    • sudo systemctl enable NetworkManager.service
    • sudo systemctl enable sddm.service
