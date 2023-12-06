#!/bin/bash

pushd ~
mkdir workspace
mkdir playground
mkdir install_env && cd install_env

# most basic env
sudo apt update
sudo apt-get install -y qemu qemu-system libncurses5-dev build-essential kernel-package curl git
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo snap install -y code python-is-python3 python3-pip tmux

# zsh install
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# docker
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# node, rust, lunarvim
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
source ~/.zshrc
nvm install -y node
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
mkdir font && pushd font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.tar.xz
tar xvf Jet*
cp -r *ttf /usr/share/fonts/
sudo fc-cache -fv

# install clang
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
sudo apt install -y libc++abi-17-dev libc++-17-dev lldb-17 clangd-17
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100
sudo update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-17 100
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-17 100
clang -v
clang++ -v

popd
