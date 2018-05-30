#!/bin/bash --

# Stuff you may need if using a laptop.

# wifi

sudo pacman -S networkmanager network-manager-applet
sudo systemctl disable wlp2s0
sudo systemctl enable NetworkManager.service

sudo pacman -S xf86-input-synaptics
