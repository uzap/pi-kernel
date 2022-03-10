#!/bin/sh

cd ..
echo "Downloading the latest ZapDragon LLVM release..."

wget -O latest.tar.xz https://cdn.zap.ooo/dl/zllvm/x86/latest.tar.xz && \
echo "Extracting compressed file..." && \
tar -xf latest.tar.xz

echo "ZapDragon LLVM installed in $PWD/zllvm-14.\n"
echo "Use the following parameter to build using zllvm:"
echo "  ./compile LLVM_DIR=$PWD/zllvm-14"
cd - > /dev/null
