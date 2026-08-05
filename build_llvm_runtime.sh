#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm_runtime.sh";

log_header "LLVM runtime";

# -------------------
#    configuration
# -------------------

log_begin "LLVM runtime configure";

mkcd "$LLVM_RUNTIME_DIR";
cmake -G Ninja \
	-Wno-dev \
	"-DLLVM_ENABLE_RUNTIMES=libunwind;libcxxabi;libcxx;compiler-rt" \
	"${CMAKE_OPTIONS[@]}" \
	"${COMPILER_RT_OPTIONS[@]}" \
	"${LIBUNWIND_OPTIONS[@]}" \
	"${LIBCXX_ABI_OPTIONS[@]}" \
	"${LIBCXX_OPTIONS[@]}" \
	"${LLVM_SOURCE}/runtimes" \
>>"$LOG_FILE";

log_end "LLVM runtime configure";

# ----------------------------
#    build and installation
# ----------------------------

if [ "$SYSTEM" = lin ]
then
	compiler_rt_components=(builtins crt);
else
	compiler_rt_components=(builtins);
fi

log_begin "libc++";
build builtins cxx cxxabi unwind;
install_ninja "${compiler_rt_components[@]}";
install "$SYSROOT_DIR" cxx cxx-headers cxx-modules cxxabi cxxabi-headers unwind unwind-headers;
log_end "libc++";

mkdir -p "${INSTALL_RUNTIME_BASE}/licences";
cp -T "${LLVM_SOURCE}/libcxx/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/libc++.txt";
cp -T "${LLVM_SOURCE}/libcxxabi/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/libc++abi.txt";
cp -T "${LLVM_SOURCE}/libunwind/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/libunwind.txt";
cp -T "${LLVM_SOURCE}/compiler-rt/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/compiler-rt.txt";

if [ "$BUILD_TYPE" = "runtime_test" ]
then
	log_begin "LLVM runtime tests";
	build check-runtimes;
	log_end "LLVM runtime tests";
fi