#!/bin/bash
# Get the value of ipaddress - netmask - gateway - dns1 - dns2 of 'ens160' interface
ipv4_address=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -w "guestinfo.ipaddress")
ipv4_netmask=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -w "guestinfo.netmask")
ipv4_gateway=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -w "guestinfo.gateway")
ipv4_dns1=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -w "guestinfo.dns1")
ipv4_dns2=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -w "guestinfo.dns2")
hname=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep -w "guestinfo.hostname")
 
ip0=$(echo "${ipv4_address}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
nm0=$(echo "${ipv4_netmask}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
gw0=$(echo "${ipv4_gateway}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
dns1=$(echo "${ipv4_dns1}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
dns2=$(echo "${ipv4_dns2}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
hname0=$(echo "${hname}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
 
# Get the value of ipaddress - netmask - gateway of 'ens192' interface
ipv4_address01=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ipaddress1")
ipv4_netmask01=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.netmask1")
 
ip1=$(echo "${ipv4_address01}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
nm1=$(echo "${ipv4_netmask01}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
 
 
# Get the subnet from netmask
import ipaddress
get_nm0=$(python3 -c "import ipaddress; print(ipaddress.IPv4Network((0,'$nm0')).prefixlen)")
get_nm1=$(python3 -c "import ipaddress; print(ipaddress.IPv4Network((0,'$nm1')).prefixlen)")
 
# Re-configure the 'ens160' interface
cat > /etc/netplan/50-cloud-init.yaml <<_EOL_
network:
  version: 2
  renderer: networkd
  ethernets:
    ens160:
      addresses:
        - $ip0/$get_nm0
      gateway4: $gw0
      nameservers:
          addresses: [$dns1, $dns2]
    ens192:
      addresses:
        - $ip1/$get_nm1
_EOL_
 
# Configure the hostname of the system
cat > /etc/hostname <<_eof_
$hname0
_eof_
 
# Apply the hostname
/bin/hostname  -F /etc/hostname
 
# Apply the config to network
/usr/sbin/netplan apply
 
# Enable the Networking
systemctl restart networking
systemctl enable networking
