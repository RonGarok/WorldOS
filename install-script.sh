#!/bin/bash

echo "🌍 WorldOS – Starting installation..."

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root."
  exit 1
fi

# Step 1: Update system
echo "🔄 Updating system packages..."
pacman -Syu --noconfirm

# Step 2: Install and activate NetworkManager
echo "🌐 Installing NetworkManager..."
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

# Step 3: Launch nmtui for manual Wi-Fi connection
echo "📡 Launching Wi-Fi setup (nmtui)..."
nmtui

# Step 4: Wait until internet connection is active
echo "⏳ Waiting for internet connection..."
until ping -c1 archlinux.org &>/dev/null; do
    echo "❌ No connection yet... please connect via nmtui."
    sleep 5
done
echo "✅ Internet connection detected!"

# Step 5: Install packages from packages.txt
echo "📦 Installing packages from packages.txt..."
xargs pacman -S --noconfirm < packages.txt

# Step 6: Create user 'worldos'
echo "👤 Creating user 'worldos'..."
useradd -m -G wheel worldos
echo "worldos:worldos" | chpasswd

# Step 7: Configure sudo access
echo "🔐 Setting up sudo permissions..."
pacman -S --noconfirm sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Step 8: Install XFCE and LightDM
echo "🖥️ Installing XFCE and LightDM..."
pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
systemctl enable lightdm

# Step 9: Apply configuration files
echo "⚙️ Applying configuration files..."

# LightDM config
cp config/lightdm.conf /etc/lightdm/lightdm.conf

# XFCE session configs
cp config/xinitrc /home/worldos/.xinitrc
cp config/xprofile /home/worldos/.xprofile

# Keyboard shortcuts
mkdir -p /home/worldos/.config/xfce4/xfconf/xfce-perchannel-xml
cp config/xfce4-keyboard-shortcuts.conf \
   /home/worldos/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

# Autostart setup
mkdir -p /home/worldos/.config/autostart
cp config/autostart.desktop /home/worldos/.config/autostart/
cp config/startup.sh /home/worldos/.config/autostart/
chmod +x /home/worldos/.config/autostart/startup.sh

# Set ownership
chown -R worldos:worldos /home/worldos/

# Step 10: Apply themes
echo "🎨 Applying themes..."
mkdir -p /usr/share/themes /usr/share/icons
cp -r themes/* /usr/share/themes/
# Icons can be added later if needed

# Final message
echo "✅ WorldOS installation complete!"
echo "🔁 You can now reboot and log in as 'worldos'. Enjoy WorldOS!"