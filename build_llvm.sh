#!/bin/bash

set -ue;

LLVM_DIR="llvm-project";
BUILD_TYPE="release";
ARCHITECTURES="host";
INSTALL_FOLDER="./install";
CORES=4;
INCLUDE_DOCS="OFF";

for a in "$@"
do
case $a in
    -llvm_dir=*)
        LLVM_DIR="${a#*=}";
        ;;
    -build_type=*)
        BUILD_TYPE="${a#*=}";
        ;;
    -architectures=*)
        ARCHITECTURES="${a#*=}";
        ;;
    -install_folder=*)
        INSTALL_FOLDER="${a#*=}";
        ;;
    -cores=*)
        CORES="${a#*=}";
        ;;
    -include_docs)
        INCLUDE_DOCS="ON";
        ;;
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
esac
done

cd "$LLVM_DIR";

if [ "$BUILD_TYPE" = "release" ]
then
    OTHER_FLAGS="\
        -DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_ASSERTIONS=OFF
        -DLLVM_BUILD_TESTS=OFF
        -DLLVM_INCLUDE_TESTS=OFF
    ";
    mkdir -p build;
    cd build;
elif [ "$BUILD_TYPE" = "test" ]
then
    OTHER_FLAGS="\
        -DCMAKE_BUILD_TYPE=RelWithDebInfo
        -DLLVM_ENABLE_ASSERTIONS=ON
        -DLLVM_INCLUDE_TESTS=ON
        -DLLVM_BUILD_TESTS=ON
    ";
    mkdir -p build_test;
    cd build_test;
else
    echo "Unknown build type.";
    exit 1;
fi

if [ "$INCLUDE_DOCS" = "ON" ]
then
    OTHER_FLAGS="$OTHER_FLAGS
        -DLLVM_ENABLE_DOXYGEN=ON
        -DLLVM_BUILD_DOCS=ON
    ";
fi

cmake -G Ninja \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_FOLDER" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD="$ARCHITECTURES" \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
    $OTHER_FLAGS \
    ../llvm;
cmake --build . "-j$CORES";