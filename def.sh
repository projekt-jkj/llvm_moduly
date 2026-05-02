# versions

LLVM_MODULY_VERSION="${LLVM_MODULY_VERSION:-22.1.5}";
LLVM_TAG="${LLVM_TAG:-llvmorg-22.1.5}";
MINGW_DEFAULT_TAG="v14.0.0";

if [ -n "${INCLUDE_MINGW:-}" ]
then
    MINGW_TAG="${MINGW_TAG:-$MINGW_DEFAULT_TAG}";
fi

# source code, build and install folders

LLVM_SOURCE="$(pwd)/src/llvm_${LLVM_TAG}";
MINGW_SOURCE="$(pwd)/src/mingw_${MINGW_TAG}";

LLVM_BUILD="$(pwd)/build/llvm_${LLVM_TAG}";
MINGW_BUILD="$(pwd)/build/mingw_${MINGW_TAG}";

INSTALL_BASE="$(pwd)/install_$LLVM_MODULY_VERSION";

# other variables

LOG_FILE="/dev/null";