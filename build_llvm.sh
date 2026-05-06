#!/bin/bash

set -ue;

BUILD_TYPE="release";
CORES=4;
INCLUDE_DOCS="OFF";
BUILD_ONLY="OFF";

LLVM_TOOLS="\
llvm-ar;llvm-cov;llvm-cxxfilt;llvm-dlltool;llvm-dwp;llvm-lib;llvm-mca;llvm-ml;llvm-nm;\
llvm-objcopy;llvm-objdump;llvm-pdbutil;llvm-profdata;llvm-profgen;llvm-ranlib;llvm-rc;\
llvm-readobj;llvm-size;llvm-strings;llvm-strip;llvm-symbolizer";
COMPILER_EXECUTABLES="clang;clang-scan-deps;lld";
CORE_COMPONENTS="${LLVM_TOOLS};${COMPILER_EXECUTABLES}";

for a in "$@"
do
case $a in
    -llvm=*)
        LLVM_VERSION="${a#*=}";
        ;;
    -install_prefix=*)
        INSTALL_PREFIX="${a#*=}";
        ;;

    -build_type=*)
        BUILD_TYPE="${a#*=}";
        ;;
    -architectures=*)
        ARCHITECTURES="${a#*=}";
        ;;
    -cores=*)
        CORES="${a#*=}";
        ;;
    -include_docs)
        INCLUDE_DOCS="ON";
        ;;
	-build_only)
		BUILD_ONLY="ON";
        ;;
	
	-log=*)
		LOG_FILE="${a#*=}";
		;;
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
esac
done

source ./def.sh;
source ./log.sh;

if [  "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "runtime_test" ]
then
    OTHER_FLAGS=(
		-DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_ASSERTIONS=OFF
        -DLLVM_BUILD_TESTS=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_DISTRIBUTION_COMPONENTS="$CORE_COMPONENTS"
	);
    mkdir -p "$LLVM_BUILD";
    cd "$LLVM_BUILD";
elif [ "$BUILD_TYPE" = "test" ]
then
    OTHER_FLAGS=(
        -DCMAKE_BUILD_TYPE=RelWithDebInfo
        -DLLVM_ENABLE_ASSERTIONS=ON
        -DLLVM_INCLUDE_TESTS=ON
        -DLLVM_BUILD_TESTS=ON
	);
    mkdir -p "${LLVM_BUILD}_test";
    cd "${LLVM_BUILD}_test";
else
    echo "Unknown build type.";
    exit 1;
fi

if [ "$INCLUDE_DOCS" = "ON" ]
then
    OTHER_FLAGS+=(
        -DLLVM_ENABLE_DOXYGEN=ON
        -DLLVM_BUILD_DOCS=ON
    );
fi

log_begin "LLVM";

cmake -G Ninja \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD="$LLVM_ARCHITECTURES" \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
    "${OTHER_FLAGS[@]}" \
    "${LLVM_SOURCE}/llvm" >>"$LOG_FILE";

log_ok "LLVM configure";

cmake --build . "-j$CORES";
log_ok "LLVM build";