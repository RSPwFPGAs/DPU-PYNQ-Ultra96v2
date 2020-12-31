#!/bin/bash

set -e

all="pynq xrt ubuntu_pkg opencv protobuf jsonc dpu dnndk"
pynq=1
xrt=1
ubuntu_pkg=1
opencv=1
protobuf=1
json_c=1
dpu_clk=1
dnndk=1

curdir=$(pwd)
for p in ${all}; do
	if [[ ${p} -eq 1 ]]; then
		echo "Upgrading ${p} ... "
		cd ${p}
		./install.sh
		cd ${curdir}
	fi
done

echo ""
echo "Upgraded PYNQ image successfully."
echo ""

