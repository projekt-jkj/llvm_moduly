# shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck source=/dev/null

source "./options/common.sh";

# --------------------
#    common options
# --------------------

CMAKE_OPTIONS=(
	"${CMAKE_RUNTIME_OPTIONS[@]}"
	"-DCMAKE_INSTALL_PREFIX=$(pwd)/install/libraries"
);
LLVM_OPTIONS=(
	"${LLVM_BASE_OPTIONS[@]}"
);
CLANG_OPTIONS=(
	"${CLANG_BASE_OPTIONS[@]}"
);
LIBCLANG_OPTIONS=(
	-DLIBCLANG_BUILD_STATIC=ON
)

DISTRIBUTIONS=();
if [ "$BUILD_CLANG_LIBRARIES" = ON ]
then
	LLVM_OPTIONS+=("-DLLVM_ENABLE_PROJECTS=clang");
	DISTRIBUTIONS+=("clang_libraries");
fi
if [ "$BUILD_LLVM_LIBRARIES" = ON ]
then
	DISTRIBUTIONS+=("llvm_libraries");
fi
if [ "$BUILD_CLANG_LIBRARIES" = ON ] || [ "$BUILD_LLVM_LIBRARIES" = ON ]
then
	LLVM_OPTIONS+=("-DLLVM_DISTRIBUTIONS=$(join "${DISTRIBUTIONS[@]}" )");
else
    echo "No library to build.";
    exit 1;
fi

# ----------------------------------
#    build type dependent options
# ----------------------------------

if [  "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "libraries_build" ]
then
	CMAKE_OPTIONS+=(-DCMAKE_BUILD_TYPE=Release);
    LLVM_OPTIONS+=(
        -DLLVM_ENABLE_ASSERTIONS=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_BUILD_TESTS=OFF
		-DCLANG_INCLUDE_TESTS=OFF
	);

	LLVM_LIBRARIES_DIR="${BUILD_BASE}/llvm_libraries_${LLVM_TAG}";
elif [ "$BUILD_TYPE" = "libraries_test" ]
then
	CMAKE_OPTIONS+=(-DCMAKE_BUILD_TYPE=RelWithDebInfo);
    LLVM_OPTIONS+=(
        -DLLVM_ENABLE_ASSERTIONS=ON
        -DLLVM_INCLUDE_TESTS=ON
        -DLLVM_BUILD_TESTS=ON
		-DCLANG_INCLUDE_TESTS=ON
	);
	LLVM_LIBRARIES_DIR="${BUILD_BASE}_test/llvm_libraries_${LLVM_TAG}";
else
    echo "Unknown build type.";
    exit 1;
fi

# -----------------------------
#    distribution definition
# -----------------------------

source "./options/components.sh";

if [ "$BUILD_CLANG_LIBRARIES" = ON ]
then
	LLVM_OPTIONS+=("-DLLVM_clang_libraries_DISTRIBUTION_COMPONENTS=$( join "${CLANG_LIBRARIES[@]}" )");
fi
if [ "$BUILD_LLVM_LIBRARIES" = ON ]
then
	LLVM_OPTIONS+=("-DLLVM_llvm_libraries_DISTRIBUTION_COMPONENTS=$( join "${LLVM_LIBRARIES[@]}" )");
fi