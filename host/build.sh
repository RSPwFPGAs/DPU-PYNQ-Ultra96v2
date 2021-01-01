#!/bin/bash

set -e

# check if vitis settings is properly sourced
if [[ -z $(vitis -version | fgrep 2019.2) ]]; then
	echo "Error: Please source Vitis 2019.2 settings."
	exit 1
fi

# check if XRT settings is properly sourced
if [[ -z ${XILINX_XRT} ]]; then
	echo "Error: Please source XRT 2019.2 settings."
	exit 1
fi

# build the Vitis platform
# put under $CURDIR/PYNQ-derivative-overlays/vitis_platform/Ultra96/platforms
CURDIR=$(pwd)
if [ ! -d "PYNQ-derivative-overlays" ]; then
	git clone https://github.com/yunqu/PYNQ-derivative-overlays.git
	cd PYNQ-derivative-overlays
	git checkout -b temp tags/v2019.2
else
	cd PYNQ-derivative-overlays
fi
cd dpu
make clean; make
cd $CURDIR/PYNQ-derivative-overlays/vitis_platform
make clean; make XSA_PATH=../dpu/dpu.xsa BOARD=Ultra96

# build hardware design
# the hardware building can take up to 3 hours
cd $CURDIR
if [ ! -d "Vitis-AI" ]; then
	git clone https://github.com/Xilinx/Vitis-AI.git
	cd Vitis-AI
	git checkout -b temp tags/v1.0
else
	cd Vitis-AI
fi
cd DPU-TRD/prj/Vitis
rm -rf dpu_conf.vh
rm -rf config_file/prj_config
cp -rf $CURDIR/dpu_conf.vh .
cp -rf $CURDIR/prj_config config_file
export SDX_PLATFORM=$CURDIR/PYNQ-derivative-overlays/vitis_platform/Ultra96/platforms/dpu/dpu.xpfm
make clean; make KERNEL=DPU DEVICE=Ultra96

# make a folder and store overlay files
# dpu.bit, dpu.hwh, and dpu.xclbin will be put under $CURDIR/dpu_overlay
if [ ! -d "$CURDIR/dpu_overlay" ]; then
	mkdir $CURDIR/dpu_overlay
fi
cp -f binary_container_1/link/vivado/vpl/prj/prj.srcs/sources_1/bd/*/hw_handoff/*.hwh \
	$CURDIR/dpu_overlay/dpu.hwh
cp -f binary_container_1/link/vivado/vpl/prj/prj.runs/impl_1/*.bit \
	$CURDIR/dpu_overlay/dpu.bit
cp -f binary_container_1/*.xclbin \
    $CURDIR/dpu_overlay/dpu.xclbin

cd ../../../../

echo ""
echo "Built PYNQ DPU design successfully."
echo ""
