#!/bin/sh

INSTALL_DIR=..
FINGERPRINT="6389B3FC107F3C0C24A8E4FCD85C9504501468CB"
KEY_IMPORTED=$(gpg --quiet --list-keys --keyid-format=long | grep -q $FINGERPRINT && \
  printf "yes")

(cd $INSTALL_DIR || exit
printf "\nDownloading the latest ZapDragon LLVM release...\n"
curl --output zllvm-latest.tar.xz https://cdn.zap.ooo/dl/zllvm/x86/latest.tar.xz

if [ "$1" != "--no-verify" ]; then
  printf "\nDownloading signature for verification...\n"
  curl --output zllvm-latest.tar.xz.asc https://cdn.zap.ooo/dl/zllvm/x86/latest.tar.xz.asc

  if [ "$KEY_IMPORTED" != "yes" ]; then
    printf "\nImporting uZap Maintainer public key...\n"
    gpg --recv-keys $FINGERPRINT

    # Check again to ensure the right key was imported
    (gpg --list-keys --keyid-format=long | grep -q $FINGERPRINT) || \
      { printf "\nExpected fingerprint was not found.\nCheck GPG keys immediately!\n"; exit 1; }
  fi

  printf "\nVerifying download...\n"
  gpg --verify zllvm-latest.tar.xz.asc zllvm-latest.tar.xz || \
    { printf "\nFailed to verify compressed tarball.\n"; exit 1; }
fi

printf "\nExtracting compressed file...\n"
tar -xf zllvm-latest.tar.xz

printf "ZapDragon LLVM installed in %s/zllvm-14.\n" "$PWD"
printf "Use the following parameter to build using zllvm:\n"
printf "  ./compile LLVM_DIR=%s/zllvm-14\n" "$PWD"
)
