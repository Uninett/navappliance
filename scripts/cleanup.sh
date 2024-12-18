# Clean up
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces

cat > /tmp/shutdown.sh <<EOF
#!/bin/sh
# Lock/delete the temporary packer installation user and shutdown the appliance.
cd /
usermod -L -e 1 packer
userdel --force --remove packer || true
rm -rf /tmp/shutdown.sh
shutdown -h -P now
EOF
chmod 755 /tmp/shutdown.sh
