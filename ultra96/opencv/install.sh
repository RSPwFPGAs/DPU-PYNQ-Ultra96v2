#!/bin/bash

set -e
set -x

version=3.4.3
cd /root

wget -O opencv.zip \
	https://github.com/opencv/opencv/archive/${version}.zip  
wget -O opencv_contrib.zip \
	https://github.com/opencv/opencv_contrib/archive/${version}.zip
unzip -o opencv.zip
unzip -o opencv_contrib.zip

mkdir opencv-${version}/build
cd opencv-${version}/build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D BUILD_WITH_DEBUG_INFO=OFF \
	-D BUILD_DOCS=OFF \
	-D BUILD_EXAMPLES=OFF \
	-D BUILD_TESTS=OFF \
	-D BUILD_opencv_ts=OFF \
	-D BUILD_PERF_TESTS=OFF \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=OFF \
	-D ENABLE_NEON=ON \
	-D WITH_LIBV4L=ON \
	-D WITH_GSTREAMER=ON \
	-D BUILD_opencv_dnn=OFF \
	-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${version}/modules \
        ../

make -j4
make install
echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf
ldconfig

cd /root
rm -rf *.zip opencv-${version} opencv_contrib-${version}
