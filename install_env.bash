#!/bin/bash
set -x
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pushd ~
mkdir -p workspace
mkdir -p playground
mkdir install_env
pushd install_env

# most basic env
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y libncurses5-dev build-essential curl git python-is-python3 python3-pip tmux terminator vim
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo snap install code --classic

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i *deb

# docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# node, rust, lunarvim
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
source ~/.bashrc
nvm install node
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. $HOME/.cargo/env

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
sudo rm -rf /squashfs-root
sudo mv squashfs-root /
sudo ln -sf /squashfs-root/AppRun /usr/bin/nvim
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc

mkdir font && pushd font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.tar.xz
tar xvf Jet*
sudo cp -r *ttf /usr/share/fonts/
sudo fc-cache -fv
popd # font

# install cmake, clang
sudo bash -c 'touch /etc/apt/apt.conf.d/99verify-peer.conf \
&& echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }"'

wget https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.sh
sudo bash cmake*.sh  --skip-license --prefix=/usr/local

sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
sudo apt install -y libc++abi-17-dev libc++-17-dev lldb-17 clangd-17 libstdc++-12-dev
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100
sudo update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-17 100
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-17 100
clang -v
clang++ -v

popd # install env
popd # home

bash $SCRIPT_DIR/set_alias.bash

cd ~ && rm -rf ~/install_env
