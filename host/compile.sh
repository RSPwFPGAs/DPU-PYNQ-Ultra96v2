#!/bin/bash

set -e

source /etc/profile.d/conda.sh

# Add ultra96 support
/opt/vitis_ai/utility/dlet -f dpu_overlay/dpu.hwh
sudo mkdir -p /opt/vitis_ai/compiler/arch/dpuv2/Ultra96
sudo cp *.dcf /opt/vitis_ai/compiler/arch/dpuv2/Ultra96/Ultra96.dcf
sudo cp -f Ultra96.json /opt/vitis_ai/compiler/arch/dpuv2/Ultra96/Ultra96.json

# Download from model zoo; adjust this for your own model
# The contents of the extracted folder (`cf_resnet50_imagenet_224_224_7.7G`) 
# will contain multiple versions of the model:
#
#* floating point frozen graph (under `float`)
#* quantized evaluation model (under `quantized`)
#* quantized deployment model (under `quantized`)
# 
# In our case we only need the following files inside the `quantized` 
# directory:
# (1) `deploy.caffemodel` and (2) `deploy.prototxt`. 

wget -O resnet50.zip \
https://www.xilinx.com/bin/public/openDownload?filename=cf_resnet50_imagenet_224_224_1.1.zip
unzip resnet50.zip

# Activate Vitis AI conda environment
export PYTHONPATH=/opt/vitis_ai/compiler 
export VAI_ROOT=/opt/vitis_ai
conda activate vitis-ai-caffe

# Call `vai_c_caffe`; adjust this for your own model
vai_c_caffe \
	--prototxt cf_resnet50_imagenet_224_224_7.7G/quantized/deploy.prototxt \
	--caffemodel cf_resnet50_imagenet_224_224_7.7G/quantized/deploy.caffemodel \
	--arch /opt/vitis_ai/compiler/arch/dpuv2/Ultra96/Ultra96.json \
	--output_dir . \
	--net_name resnet50
