# parse target
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

if [ "$PLATFORM" = "x64" ]
then
	MINGW_PLATFORM_ARGS=(--disable-lib32 --enable-lib64);
	MINGW_TARGET="x86_64-w64-mingw32";
else
	echo "Target '$TARGET' isn't supported.";
	exit 1;
fi

# LLVM variables

LLVM_MODULY_VERSION="${LLVM_MODULY_VERSION:-22.1.6}";
LLVM_TAG="${LLVM_TAG:-llvmorg-$LLVM_MODULY_VERSION}";
LLVM_SOURCE="$(pwd)/src/llvm_${LLVM_TAG}";
LLVM_BUILD="$(pwd)/build/llvm_${LLVM_TAG}";

# MinGW variables

if [ "$SYSTEM" = "win" ]
then
	MINGW_DEFAULT_TAG="v14.0.0";
    MINGW_TAG="${MINGW_TAG:-$MINGW_DEFAULT_TAG}";
	MINGW_SOURCE="$(pwd)/src/mingw_${MINGW_TAG}";
	MINGW_BUILD="$(pwd)/build/mingw_${MINGW_TAG}";
	SYSROOT="$(pwd)/build/mingw_${MINGW_TAG}_sysroot";

	LLVM_SYSTEM_NAME="Windows";
elif ["$SYSTEM" = "lin" ]
then
	LLVM_SYSTEM_NAME="Linux";
else
	echo "Target '$TARGET' isn't supported.";
fi

# install variables

if [ -v INSTALL_PREFIX ]
then
	INSTALL_BASE="${INSTALL_PREFIX}/install_${TARGET}_$LLVM_MODULY_VERSION";
else
	INSTALL_BASE="$(pwd)/install_${TARGET}_$LLVM_MODULY_VERSION";
fi

install()
{
    cmake --install . --strip --component "$1" \
		  --prefix "$INSTALL_BASE/$2"  >>"$LOG_FILE";
}

# other variables

ROOT=$(pwd);
LOG_FILE="${LOG_FILE:-/dev/null}";

log_begin()
{
	echo "=== [$1] $(date '+%H:%M:%S') ===" | tee -a "$LOG_FILE";
}
log_ok()
{
	echo "=== [$1] OK ===" | tee -a "$LOG_FILE";
}