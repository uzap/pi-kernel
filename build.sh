#!/bin/sh

# export architecture to use in build environment
export ARCH=arm
# compile with clang/llvm
export LLVM=1

# set number of jobs for make based on cpu
JOBS=`grep processor /proc/cpuinfo|wc -l`
# current date
CDATE=`date "+%Y-%m-%d"`

# options
while getopts ":ht:" option; do
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
      echo "-h     Print this Help."
      echo
      exit 0
      ;;
    t) # set config
      CONFIG=$OPTARG
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
  KERNEL=kernel7l
  PI_VER=4
else
  echo "Unsupported target: $CONFIG. Use -h for help."
  exit 1
fi

# kernel packaging function
package_kernel () {
  # make the output directory
  mkdir -p out/boot/overlays
  # install modules to output dir
  make INSTALL_MOD_PATH=out modules_install
  # clean up bloat from symlinked sources
  rm -rf out/lib/modules/*/build
  rm -rf out/lib/modules/*/source
  # copy over install script & kernel files
  cp install.sh out/
  cp arch/arm/boot/dts/*.dtb out/boot/
  cp arch/arm/boot/dts/overlays/*.dtb* out/boot/overlays/
  cp arch/arm/boot/dts/overlays/README out/boot/overlays/
  cp arch/arm/boot/zImage out/boot/$KERNEL.img
  # zip the files
  cd out
  zip -r zappi$PI_VER-kernel-$CDATE.zip .
  cd ..
}

# configure kernel using target defconfig
make "$CONFIG"_defconfig
# enable full clang lto (change FULL to THIN for ThinLTO)
scripts/config -e LTO_CLANG_FULL

# compile the kernel (save output to build.log)
logsave build.log make -j$JOBS zImage modules dtbs

# check for image before packaging
if [ ! -e arch/arm/boot/zImage ]; then
  echo "Build failed."
else
  package_kernel
fi

