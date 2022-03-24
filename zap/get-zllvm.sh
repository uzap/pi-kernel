#!/bin/sh

INSTALL_DIR=..
FINGERPRINT="6389B3FC107F3C0C24A8E4FCD85C9504501468CB"
KEY_IMPORTED=`(gpg --quiet --list-keys --keyid-format=long | grep -q $FINGERPRINT) && echo -n "yes"`

cd $INSTALL_DIR
echo "\nDownloading the latest ZapDragon LLVM release..."
curl --output zllvm-latest.tar.xz https://cdn.zap.ooo/dl/zllvm/x86/latest.tar.xz

if [ "$1" != "--no-verify" ]; then
  echo "\nDownloading signature for verification..."
  curl --output zllvm-latest.tar.xz.asc https://cdn.zap.ooo/dl/zllvm/x86/latest.tar.xz.asc

  if [ "$KEY_IMPORTED" != "yes" ]; then
    echo "\nImporting uZap Maintainer public key..."
    gpg --keyserver pgp.mit.edu --recv-keys $FINGERPRINT

    # Check again to ensure the right key was imported
    (gpg --list-keys --keyid-format=long | grep -q $FINGERPRINT) || \
      { echo "\nExpected fingerprint was not found.\nCheck GPG keys immediately!"; exit 1; }
  fi

  echo "\nVerifying download..."
  gpg --verify zllvm-latest.tar.xz.asc zllvm-latest.tar.xz || \
    { echo "\nFailed to verify compressed tarball."; exit 1; }
fi

echo "\nExtracting compressed file..."
tar -xf zllvm-latest.tar.xz

echo "ZapDragon LLVM installed in $PWD/zllvm-14.\n"
echo "Use the following parameter to build using zllvm:"
echo "  ./compile LLVM_DIR=$PWD/zllvm-14\n"
cd - > /dev/null
