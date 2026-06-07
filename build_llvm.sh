#!/bin/bash

set -ue;

BUILD_TYPE="release";
ARCHITECTURES="all";
CORES=4;
INCLUDE_DOCS="OFF";

for a in "$@"
do
case $a in
	-target=*)
		TARGET="${a#*=}";
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
source "./llvm_components.sh";
source "./options/llvm.sh";

if [  "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "llvm_build" ] \
	|| [ "$BUILD_TYPE" = "runtime_test" ]
then
    mkdir -p "$LLVM_BUILD";
    cd "$LLVM_BUILD";
elif [ "$BUILD_TYPE" = "llvm_test" ]
then
    mkdir -p "${LLVM_BUILD}_test";
    cd "${LLVM_BUILD}_test";
else
    echo "Unknown build type.";
    exit 1;
fi

log_begin "LLVM";

cmake -G Ninja \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
	"${CMAKE_OPTIONS[@]}" \
	"${LLVM_OPTIONS[@]}" \
	"${CLANG_OPTIONS[@]}" \
	"${LLD_OPTIONS[@]}" \
	"${LIBCLANG_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" >>"$LOG_FILE";

log_ok "LLVM configure";

cmake --build . "-j$CORES" >>"$LOG_FILE";
log_ok "LLVM build";

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