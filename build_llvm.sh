#!/bin/bash

set -ue;

BUILD_TYPE="release";
ARCHITECTURES="X86";
CORES=4;
INCLUDE_DOCS="OFF";

LLVM_TOOLS="\
llvm-ar;llvm-cov;llvm-cxxfilt;llvm-dlltool;llvm-dwp;llvm-lib;llvm-mca;llvm-ml;llvm-nm;\
llvm-objcopy;llvm-objdump;llvm-pdbutil;llvm-profdata;llvm-profgen;llvm-ranlib;llvm-rc;\
llvm-readobj;llvm-size;llvm-strings;llvm-strip;llvm-symbolizer";
COMPILER_EXECUTABLES="clang;clang-scan-deps;lld";
CORE_COMPONENTS="${LLVM_TOOLS};${COMPILER_EXECUTABLES}";

for a in "$@"
do
case $a in
	-target=*)
		TARGET="-target=${a#*=}";
		;;
	-log=*)
		LOG_FILE="${a#*=}";
		;;

    -llvm=*)
        LLVM_TAG="${a#*=}";
        ;;
    -mingw=*)
        MINGW_TAG="${a#*=}";
        ;;

    -build_type=*)
        BUILD_TYPE="${a#*=}";
        ;;
    -install_prefix=*)
        INSTALL_PREFIX="${a#*=}";
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
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
esac
done

source ./def.sh;

if [  "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "llvm_build" ] \
	|| [ "$BUILD_TYPE" = "runtime_test" ]
then
    LLVM_OPTIONS=(
		-DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_ASSERTIONS=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_BUILD_TESTS=OFF
	);
    mkdir -p "$LLVM_BUILD";
    cd "$LLVM_BUILD";
elif [ "$BUILD_TYPE" = "llvm_test" ]
then
    LLVM_OPTIONS=(
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
    LLVM_OPTIONS+=(
        -DLLVM_ENABLE_DOXYGEN=ON
    );
fi
if [ -v SYSROOT ]
then
    LLVM_OPTIONS+=(
		-DCMAKE_FIND_ROOT_PATH="${SYSROOT}" \
  		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
  		-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
    );
fi

log_begin "LLVM";

cmake -G Ninja \
	"-CMAKE_SYSTEM_NAME=$LLVM_SYSTEM_NAME" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD="$ARCHITECTURES" \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
	"${LLVM_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" >>"$LOG_FILE";

log_ok "LLVM configure";

cmake --build . "-j$CORES" >>"$LOG_FILE";
log_ok "LLVM build";

if [ "$INCLUDE_DOCS" = "ON" ]
then
    cmake --build . --target docs "-j$CORES" >>"$LOG_FILE";
	log_ok "LLVM documentation";
fi

if [ "$BUILD_TYPE" = "llvm_build" ]
then
	exit 1;
elif [ "$BUILD_TYPE" = "test" ]
then
	log_begin "LLVM tests";
	cmake --build . --target check "-j$CORES" >>"$LOG_FILE";
	log_ok "LLVM tests";
	exit 1;
else
	# not implemented yet
	log_ok "LLVM install";
fi