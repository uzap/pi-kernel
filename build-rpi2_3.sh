#!/bin/sh
export ARCH=arm
export LLVM=1

KERNEL=kernel7
CONFIG=bcm2709_defconfig
JOBS=`grep processor /proc/cpuinfo|wc -l`
cdate=`date "+%Y-%m-%d"`

make $CONFIG
scripts/config -e LTO_CLANG_FULL

logsave build.log make -j$JOBS zImage modules dtbs

if [ -e arch/arm/boot/zImage ]; then
  mkdir -p out/boot/overlays
  make INSTALL_MOD_PATH=out modules_install
  rm -rf out/lib/modules/*/build
  rm -rf out/lib/modules/*/source
  cp arch/arm/boot/dts/*.dtb out/boot/
  cp arch/arm/boot/dts/overlays/*.dtb* out/boot/overlays/
  cp arch/arm/boot/dts/overlays/README out/boot/overlays/
  cp arch/arm/boot/zImage out/boot/$KERNEL.img
  cd out
  zip -r zappi2_3-kernel-$cdate.zip .
  cd ..
else
  echo "Build failed."
fi

