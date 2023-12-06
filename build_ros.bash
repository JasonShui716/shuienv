#!/bin/bash

pushd ~/workspace/ros*
colcon build --symlink-install --cmake-force-configure --cmake-args -DCMAKE_C_COMPILER=clang --cmake-args -DCMAKE_CXX_COMPILER=clang++ --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

