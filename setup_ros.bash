#!/bin/bash
set -e

BASIC_CONFIGURE=true
echo "Have you done basic configure before? [y/N]"
read answer

case $answer in
    [Yy]* ) BASIC_CONFIGURE=false;;
    [Nn]* ) ;;
    * ) echo "Please answer yes or no.";;
esac

if [[ $BASIC_CONFIGURE == true ]] ; then
	sudo apt update && sudo apt install locales
	sudo locale-gen en_US en_US.UTF-8
	sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
	export LANG=en_US.UTF-8
	
	locale  # verify settings
	
	sudo apt install software-properties-common
	sudo add-apt-repository universe
	
	sudo apt update && sudo apt install curl -y
	sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
	
	sudo apt update && sudo apt install -y \
	  python3-flake8-docstrings \
	  python3-pip \
	  python3-pytest-cov \
	  python3-flake8-blind-except \
	  python3-flake8-builtins \
	  python3-flake8-class-newline \
	  python3-flake8-comprehensions \
	  python3-flake8-deprecated \
	  python3-flake8-import-order \
	  python3-flake8-quotes \
	  python3-pytest-repeat \
	  python3-pytest-rerunfailures \
	  ros-dev-tools
	
	mkdir -p ~/workspace/ros2_iron/src
	cd ~/workspace/ros2_iron
	vcs import --input https://raw.githubusercontent.com/ros2/ros2/iron/ros2.repos src
	
	sudo apt upgrade
	sudo rosdep init
	rosdep update
	rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"
fi

cd ~/workspace/ros2_iron/

REBUILD_BINUTILS=false
echo "!!!!!!!!!DANGEROUS!!!!!!!!Rebuild binutils with fPIC? [y/N]"
read answer

case $answer in
    [Yy]* ) REBUILD_BINUTILS=true;;
    [Nn]* ) ;;
    * ) echo "Please answer yes or no.";;
esac

if [[ $REBUILD_BINUTILS == true ]] ; then
	mkdir binutils_fpic && pushd binutils_fpic
	wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz
	tar xvf bin* && pushd binutils-2.41
	CFLAGS="-fPIC" LDFLAGS="-fPIC" ./configure --enable-shared --prefix=/usr/lib
	make -j`nproc` && sudo make install
	popd
	popd
	rm -rf binutils_fpic
fi

. ~/workspace/ros2_iron/install/local_setup.bash

