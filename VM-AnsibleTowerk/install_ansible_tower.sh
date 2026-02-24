#!/usr/bin/env bash
set -euo pipefail

# install_ansible_tower.sh
# Ubuntu bootstrap for Ansible Tower prerequisites + VM guest tools.

if [[ "${EUID}" -ne 0 ]]; then
  echo "Uruchom ten skrypt jako root (sudo)."
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo "Nie mozna wykryc systemu operacyjnego."
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "Ten skrypt jest przeznaczony dla Ubuntu. Wykryto: ${ID:-nieznany}"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/6] Aktualizacja systemu..."
apt-get update -y
apt-get upgrade -y

echo "[2/6] Instalacja podstawowych pakietow..."
apt-get install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  net-tools \
  unzip \
  gnupg \
  lsb-release \
  ca-certificates \
  software-properties-common \
  python3 \
  python3-pip \
  ansible

echo "[3/6] Ustawianie hasla root..."
echo "root:1" | chpasswd

echo "[4/6] Konfiguracja uzytkownika chris..."
if id -u chris >/dev/null 2>&1; then
  echo "Uzytkownik chris juz istnieje - aktualizuje haslo."
else
  useradd -m -s /bin/bash chris
fi
echo "chris:1" | chpasswd
usermod -aG sudo chris

echo "[5/6] Wykrywanie srodowiska VM i instalacja guest tools..."
virt_type="$(systemd-detect-virt || true)"

if [[ "${virt_type}" == "kvm" || "${virt_type}" == "qemu" ]]; then
  # Najczestszy przypadek dla VM na Proxmox VE
  echo "Wykryto srodowisko KVM/QEMU (np. Proxmox). Instaluje qemu-guest-agent..."
  apt-get install -y qemu-guest-agent
  systemctl enable --now qemu-guest-agent
elif [[ "${virt_type}" == "vmware" ]]; then
  echo "Wykryto VMware. Instaluje open-vm-tools..."
  apt-get install -y open-vm-tools
  systemctl enable --now open-vm-tools
else
  echo "Nie wykryto Proxmox/KVM ani VMware. Pomijam instalacje guest tools."
fi

echo "[6/6] Informacja o Ansible Tower..."
cat <<'INFO'
Ten skrypt instaluje wymagania bazowe i Ansible.
Ansible Tower (obecnie Red Hat Ansible Automation Platform) wymaga
oficjalnego instalatora/licencji od Red Hat.

Po skopiowaniu oficjalnego instalatora na serwer uruchom instalacje
zgodnie z dokumentacja Red Hat.
INFO

echo "Gotowe."
