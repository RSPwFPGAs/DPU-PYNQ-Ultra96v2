#!/bin/bash

set -e
set -x

# download dnndk 1.0 and install it
cd /home/xilinx
wget -O vitis-ai_v1.0_dnndk.ultra96.tar.gz https://www.xilinx.com/bin/public/openDownload?filename=vitis-ai_v1.0_dnndk.ultra96.tar.gz
tar -xvf vitis-ai_v1.0_dnndk.ultra96.tar.gz
cd pkgs
chmod 777 install.sh
./install.sh
rm -rf /home/xilinx/pkgs /home/xilinx/vitis-ai_v1.0_dnndk.ultra96.tar.gz
