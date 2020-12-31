#   Copyright (c) 2020, Xilinx, Inc.
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   1.  Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#   2.  Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#   3.  Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived from
#       this software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#   OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import os
import re
import subprocess
import pynq
from pynq import Register


__author__ = "Yun Rock Qu"
__copyright__ = "Copyright 2020, Xilinx"
__email__ = "pynq_support@xilinx.com"


DATA_WIDTH_REGISTER = 0xFF419000


def set_data_width(width_option):
    """Set AXI port data width.

    We need to select the 32/64/128-bit data width for the slave registers.
    Each of the following values corresponds to a specific data width.
    The reason why we need this step, is that for some petalinux BSP's
    (e.g. `xilinx-zcu104-v2019.1-final.bsp`), the AXI lite interface width
    is not set properly. This step may not be needed for future PYNQ
    releases.

    00: 32-bit AXI data width (default)
    01: 64-bit AXI data width
    10: 128-bit AXI data width (reset value)
    11: reserved

    Parameters
    ----------
    width_option : int
        The width options ranging from 0 to 3.

    """
    if width_option not in range(4):
        raise ValueError("Data width option can only be set to 0, 1, 2, 3.")
    Register(0xFF419000)[9:8] = width_option


class DpuOverlay(pynq.Overlay):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.overlay_dirname = os.path.dirname(self.bitfile_name)
        self.overlay_basename = os.path.basename(self.bitfile_name)
        self.dest_lib_dir = "/usr/lib"

    def download(self):
        """Download the overlay.

        This method overwrites the existing `download()` method defined in
        the overlay class. It will download the bitstream, set AXI data width,
        copy xclbin and ML model files.

        """
        super().download()
        self.overlay_dirname = os.path.dirname(self.bitfile_name)
        self.overlay_basename = os.path.basename(self.bitfile_name)
        self.dest_lib_dir = "/usr/lib"

        set_data_width(0)
        self.copy_xclbin()

    def copy_xclbin(self):
        """Copy the xclbin file to a specific location.

        This method will copy the xclbin file into the destination directory to
        make sure DNNDK libraries can work without problems.

        The xclbin file, if not set explicitly, is required to be located
        in the same folder as the bitstream and hwh files.

        The destination folder by default is `/usr/lib`.

        """
        abs_xclbin = self.overlay_dirname + "/" + \
            self.overlay_basename.rstrip(".bit") + ".xclbin"
        if not os.path.isfile(abs_xclbin):
            raise ValueError(
                "File {} does not exist.".format(abs_xclbin))

        if not os.path.isdir(self.dest_lib_dir):
            raise ValueError(
                "Folder {} does not exist.".format(self.dest_lib_dir))
        _ = subprocess.check_output(["cp", "-f",
                                     abs_xclbin, self.dest_lib_dir])

    def load_model(self, model_elf):
        """Load DPU models under a specific location.

        This method will compile the ML model `*.elf` binary file,
        compile it into `*.so` file located in the destination directory
        on the target. This will make sure DNNDK libraries can work
        without problems.

        The ML model file, if not set explicitly, is required to be located
        in the same folder as the bitstream and hwh files.

        The destination folder by default is `/usr/lib`.

        By default, we assume the `*.elf` file has a naming convention of:
        `dpu_<kernel_name>[_0].elf`.

        Parameters
        ----------
        model_elf : str
            The name of the ML model binary. Can be absolute or relative path.

        """
        if os.path.isfile(model_elf):
            abs_model = model_elf
        elif os.path.isfile(self.overlay_dirname + "/" + model_elf):
            abs_model = self.overlay_dirname + "/" + model_elf
        else:
            raise ValueError(
                "File {} does not exist.".format(model_elf))
        if not os.path.isdir(self.dest_lib_dir):
            raise ValueError(
                "Folder {} does not exist.".format(self.dest_lib_dir))

        kernel_name_0 = abs_model.split('/')[-1].lstrip(
            'dpu_').rstrip('.elf')
        kernel_name = re.sub('_0$', '', kernel_name_0)
        model_so = "libdpumodel{}.so".format(kernel_name)
        _ = subprocess.check_output(
            ["gcc", "-fPIC", "-shared", abs_model, "-o",
             os.path.join(self.dest_lib_dir, model_so)])
