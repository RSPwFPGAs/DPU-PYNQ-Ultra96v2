#!/bin/bash

set -e

source /etc/profile.d/conda.sh

# Add ultra96 support
/opt/vitis_ai/utility/dlet -f dpu_overlay/dpu.hwh
sudo mkdir -p /opt/vitis_ai/compiler/arch/dpuv2/Ultra96
sudo cp *.dcf /opt/vitis_ai/compiler/arch/dpuv2/Ultra96/Ultra96.dcf
sudo cp -f Ultra96.json /opt/vitis_ai/compiler/arch/dpuv2/Ultra96/Ultra96.json

# Activate Vitis AI conda environment
export PYTHONPATH=/opt/vitis_ai/compiler 
export VAI_ROOT=/opt/vitis_ai
conda activate vitis-ai-tensorflow

vai_c_tensorflow \
	--frozen_pb models/poly_yolo_dpu/quantized/deploy_model.pb \
	--arch /opt/vitis_ai/compiler/arch/dpuv2/Ultra96/Ultra96.json \
	--output_dir . \
	--net_name tf_poly_yolo \
	--quant_info
