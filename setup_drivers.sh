#!/bin/bash
# Assumes a Google Cloud VM Instance with
# a single L4 GPU, 
# 12 vCPUs, 
# 48gb RAM, 
# Ubuntu 22.04 LTS (x86/64)
# 100GB Disk
# Full access to all Cloud APIs
# Allowance for HTTP traffic

set -e




# update and upgrade pre-listed packages
apt update && sudo apt upgrade -y

# install drivers with GCP's prebuilt installer
apt install -y linux-headers-$(uname -r)
apt install -y nvidia-driver-550

# reboot
reboot