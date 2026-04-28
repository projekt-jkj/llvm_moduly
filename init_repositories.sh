#!/bin/bash

set -ue;

LLVM_TAG="llvmorg-22.1.4";
MINGW_DEFAULT_TAG="v14.0.0";

for a in "$@"
do
case $a in
    -llvm=*)
        LLVM_TAG="${a#*=}";
        ;;
    -mingw)
        MINGW_TAG="$MINGW_DEFAULT_TAG";
        ;;
    -mingw=*)
        MINGW_TAG="${a#*=}";
        ;;
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
esac
done

clone()
{
    if [ ! -d "$3" ]
    then
        git clone --depth 1 -b "$1" "$2" "$3";
    fi
}

LLVM_DIR="llvm-project_$LLVM_TAG";
clone "$LLVM_TAG" "https://github.com/llvm/llvm-project.git" "src/$LLVM_DIR";
echo "LLVM_DIR=$LLVM_DIR";

if [ -v MINGW_TAG ]
then
    MINGW_DIR="mingw-w64_$MINGW_TAG";
    clone "$MINGW_TAG" "https://github.com/mingw-w64/mingw-w64.git" "src/$MINGW_DIR";
    echo "MINGW_DIR=$MINGW_DIR";
fi