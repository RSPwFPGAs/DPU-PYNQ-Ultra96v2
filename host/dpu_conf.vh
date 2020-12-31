`define B1600
`define URAM_DISABLE
`ifdef URAM_ENABLE
    `define def_UBANK_IMG_N          5
    `define def_UBANK_WGT_N          17
    `define def_UBANK_BIAS           1
`elsif URAM_DISABLE
    `define def_UBANK_IMG_N          0
    `define def_UBANK_WGT_N          0
    `define def_UBANK_BIAS           0
`endif
`define RAM_USAGE_LOW
`define CHANNEL_AUGMENTATION_DISABLE
`define DWCV_ENABLE
`define POOL_AVG_ENABLE
`define RELU_LEAKYRELU_RELU6
`define DSP48_USAGE_HIGH
