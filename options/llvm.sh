# shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck source=/dev/null

ACTIVE_PROJECTS="clang;lld";
DISTRIBUTIONS=("llvm_clang");

if [ "$BUILD_CLANG_TOOLS" = ON ]
then
	ACTIVE_PROJECTS="${ACTIVE_PROJECTS};clang-tools-extra";
	DISTRIBUTIONS+=("clang_tools");
fi
if [ "$BUILD_LLDB" = ON ]
then
	ACTIVE_PROJECTS="$ACTIVE_PROJECTS;lldb";
	DISTRIBUTIONS+=("lldb");
fi

# --------------------
#    common options
# --------------------

CMAKE_OPTIONS=(
	"-DCMAKE_SYSTEM_NAME=$LLVM_SYSTEM_NAME"
);
LLVM_OPTIONS=(
	"-DLLVM_ENABLE_PROJECTS=$ACTIVE_PROJECTS"
	"-DLLVM_DISTRIBUTIONS=$(join "${DISTRIBUTIONS[@]}" )"
	-DLLVM_BUILD_LLVM_DYLIB=OFF
    -DLLVM_LINK_LLVM_DYLIB=OFF
    -DLLVM_ENABLE_BINDINGS=OFF
    "-DLLVM_TARGETS_TO_BUILD=$ARCHITECTURES"
	"-DLLVM_DEFAULT_TARGET_TRIPLE=$LLVM_TARGET"
);
CLANG_OPTIONS=(
	-DCLANG_VENDOR="llvm_moduly ($LLVM_MODULY_VERSION)"
	-DCLANG_DEFAULT_RTLIB=compiler-rt
	-DCLANG_DEFAULT_UNWINDLIB=libunwind
	-DCLANG_DEFAULT_CXX_STDLIB=libc++
	-DCLANG_DEFAULT_LINKER=lld
	-DCLANG_RESOURCE_DIR=../resource
	-DDEFAULT_SYSROOT=../sysroot
);
LLD_OPTIONS=(
	-DLLD_VENDOR="llvm_moduly ($LLVM_MODULY_VERSION)"
);

# ----------------------------------
#    build type dependent options
# ----------------------------------

if [  "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "llvm_build" ] \
	|| [ "$BUILD_TYPE" = "runtime_build" ]|| [ "$BUILD_TYPE" = "runtime_test" ]
then
	CMAKE_OPTIONS+=(-DCMAKE_BUILD_TYPE=Release);
    LLVM_OPTIONS+=(
        -DLLVM_ENABLE_ASSERTIONS=OFF
        -DLLVM_INCLUDE_TESTS=OFF
        -DLLVM_BUILD_TESTS=OFF
		-DCLANG_INCLUDE_TESTS=OFF
	);

	LLVM_BUILD_DIR="${BUILD_BASE}/llvm_${LLVM_TAG}";
elif [ "$BUILD_TYPE" = "llvm_test" ]
then
	CMAKE_OPTIONS+=(-DCMAKE_BUILD_TYPE=RelWithDebInfo);
    LLVM_OPTIONS+=(
        -DLLVM_ENABLE_ASSERTIONS=ON
        -DLLVM_INCLUDE_TESTS=ON
        -DLLVM_BUILD_TESTS=ON
		-DCLANG_INCLUDE_TESTS=ON
	);
	LLVM_BUILD_DIR="${BUILD_BASE}_test/llvm_${LLVM_TAG}";
else
    echo "Unknown build type.";
    exit 1;
fi

# -----------------------------
#    distribution definition
# -----------------------------

source "./options/llvm_components.sh";
LLVM_OPTIONS+=("-DLLVM_llvm_clang_DISTRIBUTION_COMPONENTS=$( join "${LLVM_CLANG[@]}" )");

if [ "$BUILD_CLANG_TOOLS" = ON ]
then
	LLVM_OPTIONS+=("-DLLVM_clang_tools_DISTRIBUTION_COMPONENTS=$( join "${CLANG_TOOLS[@]}" )");
fi
if [ "$BUILD_LLDB" = ON ]
then
	LLVM_OPTIONS+=("-DLLVM_lldb_DISTRIBUTION_COMPONENTS=$( join "${LLDB[@]}" )");
fi