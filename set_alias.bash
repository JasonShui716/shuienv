#!/bin/bash

echo 'alias cmake-clang="cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"' >> $HOME/.bashrc

echo 'alias docker-run-it="docker run -it \
    --network=host \
    -e "QT_X11_NO_MITSHM=1" \
    -e GDK_SCALE \
    -e GDK_DPI_SCALE \
    -e DISPLAY=unix$DISPLAY \
    --restart=unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME:/workspace \
    -w /workspace \
    --privileged --security-opt seccomp=unconfined \
    --env="DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix"' >> $HOME/.bashrc

