#!/bin/sh

CLANG_VERSION=$(clang --version | head -1)
FILE_VERSION=$(cat "$PWD"/clangversion.txt)

echo "$CLANG_VERSION"

if [ "$CLANG_VERSION" != "$FILE_VERSION" ]; then
  echo "$CLANG_VERSION" > clangversion.txt
  git add clangversion.txt
  git commit -m "clangversion: $CLANG_VERSION"
else
  echo "Current clang set in clangversion is already the current version."
fi
