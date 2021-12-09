#!/bin/sh

# compile with clang/llvm
export LLVM=1

# set number of jobs for make based on cpu
JOBS=`grep processor /proc/cpuinfo|wc -l`
# current date
CDATE=`date "+%Y-%m-%d"`

# options
while getopts ":h:t:T:" option; do
  case $option in
    h) # display help
      echo "Compile and zip a kernel for Raspberry Pi."
      echo
      echo "Example: ./build.sh -t bcm2711"
      echo "options:"
      echo "-t     Target Raspberry Pi defconfig for the kernel build."
      echo "                            device:      option:"
      echo "                                RPi 0/1      bcmrpi"
      echo "                                RPi 2/3      bcm2709"
      echo "                                RPi   4      bcm2711"
      echo "-T     Build using 64-bit defconfig (if supported)."
      echo "                            device:      option:"
      echo "                                RPi   3      bcmrpi3"
      echo "                                RPi   4      bcm2711"
      echo "-h     Print this Help."
      echo
      exit 0
      ;;
    t) # set config
      CONFIG=$OPTARG
      BITS=""
      export ARCH=arm
      ;;
    T) # set 64-bit config
      CONFIG=$OPTARG
      BITS=64
      export ARCH=arm64
      ;;
   \?) # catch invalid option
      echo "Invalid option. Use -h for help."
      exit 1
      ;;
  esac
done

# require a target
if [ -z "$CONFIG" ]; then
  echo "No target defconfig. Requires a valid target [-t]. Use -h for help."
  exit 1
fi

# check if target is a supported config
if [ "$CONFIG" = "bcmrpi" ]; then
  KERNEL=kernel
  PI_VER=""
elif [ "$CONFIG" = "bcm2709" ]; then
  KERNEL=kernel7
  PI_VER=2_3
elif [ "$CONFIG" = "bcm2711" ]; then
  # check for 64-bit
  if [ "$BITS" = "64" ]; then
    KERNEL=kernel8
  else
    KERNEL=kernel7l
  fi
  PI_VER=4
elif [ "$CONFIG" = "bcmrpi3" ]; then
  KERNEL=kernel8
  PI_VER=3
else
  echo "Unsupported target: $CONFIG. Use -h for help."
  exit 1
fi

# kernel packaging function
package_kernel () {
  # make the output directory
  mkdir -p out/boot/overlays
  # install modules to output dir
  make INSTALL_MOD_PATH=out modules_install || exit 1
  # clean up bloat from symlinked sources
  rm -rf out/lib/modules/*/build
  rm -rf out/lib/modules/*/source
  # copy over install script & kernel files
  cp install.sh out/
  if [ ! -n "$BITS" ]; then
    cp arch/arm/boot/dts/*.dtb out/boot/
    cp arch/arm/boot/dts/overlays/*.dtb* out/boot/overlays/
    cp arch/arm/boot/dts/overlays/README out/boot/overlays/
    cp arch/arm/boot/zImage out/boot/$KERNEL.img
  else
    cp arch/arm64/boot/dts/broadcom/*.dtb out/boot/
    cp arch/arm64/boot/dts/overlays/*.dtb* out/boot/overlays/
    cp arch/arm64/boot/dts/overlays/README out/boot/overlays/
    cp arch/arm64/boot/Image out/boot/$KERNEL.img
  fi
  # zip the files
  cd out
  zip -r zappi$PI_VER-kernel$BITS-$CDATE.zip .
  cd ..
}

# configure kernel using target defconfig
make "$CONFIG"_defconfig
# enable full clang lto (change FULL to THIN for ThinLTO)
scripts/config -e LTO_CLANG_FULL

# configure cfi for arm64
if [ "$BITS" = 64 ]; then
  scripts/config -e CFI_CLANG
  scripts/config -e CFI_CLANG_SHADOW
  scripts/config -d CFI_PERMISSIVE
fi

# compile the kernel (save output to build.log)
if [ ! -n "$BITS" ]; then
  logsave build.log make -j$JOBS zImage modules dtbs || exit 1
else
  logsave build.log make -j$JOBS Image modules dtbs || exit 1
fi

package_kernel

