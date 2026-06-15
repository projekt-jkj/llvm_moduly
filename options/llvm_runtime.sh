# shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck source=/dev/null

CMAKE_OPTIONS=(
	"-DCMAKE_SYSTEM_NAME=$LLVM_SYSTEM_NAME"
	"-DCMAKE_INSTALL_PREFIX=${INSTALL_BASE}/tmp"
	-DCMAKE_C_COMPILER_WORKS=ON
	-DCMAKE_CXX_COMPILER_WORKS=ON
	"-DCMAKE_C_COMPILER=${INSTALL_BASE}/llvm_clang/bin/clang.exe"
	"-DCMAKE_CXX_COMPILER=${INSTALL_BASE}/llvm_clang/bin/clang++.exe"
	"-DCMAKE_AR=${INSTALL_BASE}/llvm_clang/bin/llvm-ar.exe"
	"-DCMAKE_RANLIB=${INSTALL_BASE}/llvm_clang/bin/llvm-ranlib.exe"
	"-DCMAKE_C_COMPILER_TARGET=${LLVM_TARGET}"
);
BUILTINS_OPTIONS=(
	-DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON
    -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=OFF
);

if [ "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "runtime_build" ]
then
	CMAKE_OPTIONS+=(-DCMAKE_BUILD_TYPE=Release);
	LLVM_BUILTINS_DIR="${BUILD_BASE}/llvm_builtins_${LLVM_TAG}";
elif [ "$BUILD_TYPE" = "runtime_test" ]
then
	CMAKE_OPTIONS+=(-DCMAKE_BUILD_TYPE=RelWithDebInfo);
	LLVM_BUILTINS_DIR="${BUILD_BASE}_test/llvm_builtins_${LLVM_TAG}";
else
    echo "Unknown build type.";
    exit 1;
fi

if [ -v SYSROOT ]
then
    CMAKE_OPTIONS+=(
		-DCMAKE_SYSROOT="${SYSROOT}"
    );
fi