# shellcheck shell=bash

export CC="$CLANG";
export CXX="$CLANG_PP";
export CPP="$CLANG_CPP"
export AR="$LLVM_AR"
export RANLIB="$LLVM_RANLIB"
export DLLTOOL="$LLVM_DLLTOOL"

export CFLAGS="-resource-dir=${RESOURCE_DIR} --sysroot=${SYSROOT_DIR}";
export CXXFLAGS="-resource-dir=${RESOURCE_DIR} --sysroot=${SYSROOT_DIR}";
