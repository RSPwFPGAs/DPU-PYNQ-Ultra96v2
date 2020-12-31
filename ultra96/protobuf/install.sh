#!/bin/bash

set -e
set -x

# build and install protobuf
cd /root
git clone https://github.com/protocolbuffers/protobuf.git protobuf-git
cd protobuf-git
git checkout -b temp tags/v3.6.1
git submodule update --init --recursive
./autogen.sh
./configure --with-protoc=protoc
make
make install
echo "/usr/local/lib" >> /etc/ld.so.conf.d/protobuf.conf
ldconfig

# cleanup
cd /root
rm -rf protobuf-git

