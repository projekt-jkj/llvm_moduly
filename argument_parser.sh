# shellcheck shell=bash
# shellcheck disable=SC2034

: "${LLVM_MODULY_VERSION:=22.1.7}";

# -------------------------------------------
#    default values for optional arguments
# -------------------------------------------

LLVM_TAG="llvmorg-$LLVM_MODULY_VERSION";
MINGW_TAG="v14.0.0";
LOG_FILE="/dev/stdout";
CORES=$(nproc);
INSTALL_PREFIX=$(pwd);

BUILD_TYPE=release;
INCLUDE_DOCS=OFF;

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
    -include_docs)
		INCLUDE_DOCS=ON;
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

SYSTEM=${TARGET%%_+([^_])};
PLATFORM=${TARGET##+([^_])_};

if [ -z "$SYSTEM" ] || [ -z "$PLATFORM" ]
then
	echo "Invalid target '$TARGET'.";
	exit 1;
fi

# -------------------------
#    path initialization
# -------------------------

LLVM_SOURCE="$(pwd)/source/llvm_${LLVM_TAG}";
MINGW_SOURCE="$(pwd)/source/mingw_${MINGW_TAG}";

BUILD_BASE="$(pwd)/build";
INSTALL_BASE="$(pwd)/install";