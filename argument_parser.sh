# shellcheck shell=bash
# shellcheck disable=SC2034

: "${LLVM_MODULY_VERSION:=Argon preview}";

# -------------------------------------------
#    default values for optional arguments
# -------------------------------------------

LLVM_TAG="llvmorg-22.1.8";
MINGW_TAG="v14.0.0";
MUSL_TAG="v1.2.6";

LOG_FILE="/dev/stdout";
CORES=$(nproc);
INSTALL_PREFIX=$(pwd)/install;

BUILD_TYPE=release;

ARCHITECTURES="all";
BUILD_CLANG_TOOLS=OFF;
BUILD_LLDB=OFF;

# -----------------------
#    main parsing loop
# -----------------------

for a in "$@"
do
case $a in
# common options
	-llvm=*)
		LLVM_TAG="llvmorg-${a#*=}";
		;;
	-mingw=*)
		MINGW_TAG="${a#*=}";
		;;
	-musl=*)
		MUSL_TAG="${a#*=}";
		;;

	-target=*)
		TARGET="${a#*=}";
		;;
	-log=*)
		LOG_FILE="${a#*=}";
		;;
    -cores=*)
        CORES="${a#*=}";
        ;;
	-install_prefix=*)
        INSTALL_PREFIX="${a#*=}";
		;;

# LLVM options
	-build_type=*)
        BUILD_TYPE="${a#*=}";
		;;

# build_llvm options
	-architectures=*)
        ARCHITECTURES="${a#*=}";
		;;
	-clang_tools)
		BUILD_CLANG_TOOLS=ON;
		;;
	-lldb)
		BUILD_LLDB=ON;
		;;
	-msys=*)
		MSYS="${a#*=}";
		;;

# fail if argument is unknown
# if the argument is known but not used,
# don't fail or warn (this is due to simplicity)
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
	esac
done

# -----------------------
#    target validation
# -----------------------

if [ ! -v "TARGET" ]
then
    echo "Target not specified.";
	exit 1;
fi

shopt -s extglob;
SYSTEM=${TARGET%%_+([^_])};
PLATFORM=${TARGET##+([^_])_};

# both system and platform must be non-empty
if [ -z "$SYSTEM" ] || [ -z "$PLATFORM" ]
then
	echo "Invalid target '$TARGET'.";
	exit 1;
fi

# platform name is used to initialize MinGW options
if [ "$PLATFORM" = "x64" ]
then
	MINGW_PLATFORM_ARGS=(--disable-lib32 --enable-lib64);
	MINGW_TARGET="x86_64-w64-mingw32";
else
	echo "Target '$TARGET' isn't supported (unknown platform).";
	exit 1;
fi

# system name is used to initialize CMAKE_SYSTEM_NAME option for LLVM build
if [ "$SYSTEM" = "win" ]
then
	EXE=".exe";
	LLVM_SYSTEM_NAME="Windows";
elif [ "$SYSTEM" = "lin" ]
then
	EXE="";
	LLVM_SYSTEM_NAME="Linux";
else
	echo "Target '$TARGET' isn't supported (unknown system).";
    exit 1;
fi

# full target is used to initialize default target for Clang
# and for LLVM runtime build
if [ "$TARGET" = "win_x64" ]
then
	LLVM_TARGET="x86_64-jkj-windows-gnu";
elif [ "$TARGET" = "lin_x64" ]
then
	LLVM_TARGET="x86_64-jkj-linux-musl";
else
	echo "Target '$TARGET' isn't supported (unknown target).";
    exit 1;
fi

# -------------------------
#    path initialization
# -------------------------

LLVM_SOURCE="$(pwd)/source/llvm_${LLVM_TAG}";
MINGW_SOURCE="$(pwd)/source/mingw_${MINGW_TAG}";
MUSL_SOURCE="$(pwd)/source/musl_${MUSL_TAG}";

BUILD_BASE="$(pwd)/build/${TARGET}";
INSTALL_TOOLS_BASE="${INSTALL_PREFIX}/tools.${TARGET}";
INSTALL_RUNTIME_BASE="${INSTALL_PREFIX}/runtime.${TARGET}";

CLANG="${INSTALL_TOOLS_BASE}/llvm_clang/bin/clang${EXE}";
CLANG_PP="${INSTALL_TOOLS_BASE}/llvm_clang/bin/clang++${EXE}";
RESOURCE_DIR="${INSTALL_RUNTIME_BASE}/resource";
SYSROOT_DIR="${INSTALL_RUNTIME_BASE}/sysroot";