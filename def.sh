# LLVM variables

LLVM_MODULY_VERSION="${LLVM_MODULY_VERSION:-22.1.5}";
LLVM_TAG="${LLVM_TAG:-llvmorg-22.1.5}";
LLVM_SOURCE="$(pwd)/src/llvm_${LLVM_TAG}";
LLVM_BUILD="$(pwd)/build/llvm_${LLVM_TAG}";

# MinGW variables

if [ -n "${INCLUDE_MINGW:-}" ]
then
	MINGW_DEFAULT_TAG="v14.0.0";
    MINGW_TAG="${MINGW_TAG:-$MINGW_DEFAULT_TAG}";
	MINGW_SOURCE="$(pwd)/src/mingw_${MINGW_TAG}";
	MINGW_BUILD="$(pwd)/build/mingw_${MINGW_TAG}";
fi

# install variables

INSTALL_BASE="$(pwd)/install_$LLVM_MODULY_VERSION";

# other variables

LOG_FILE="/dev/null";

log_begin()
{
	echo "=== [$1] $(date '+%H:%M:%S') ===" | tee -a "$LOG_FILE";
}
log_ok()
{
	echo "=== [$1] OK ===" | tee -a "$LOG_FILE";
}