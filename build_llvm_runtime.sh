#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/components.sh";
source "./options/llvm_runtime.sh";

log_header "LLVM runtime";

# ------------------------------------------------
#    libc++ libc++abi, libunwind, LLVM builtins
# ------------------------------------------------

log_begin "LLVM runtime configure";

mkcd "$LLVM_RUNTIME_DIR";
cmake -G Ninja \
	-Wno-dev \
	"-DLLVM_ENABLE_RUNTIMES=libunwind;libcxxabi;libcxx;compiler-rt" \
	"${CMAKE_OPTIONS[@]}" \
	"${BUILTINS_OPTIONS[@]}" \
	"${LIBUNWIND_OPTIONS[@]}" \
	"${LIBCXX_ABI_OPTIONS[@]}" \
	"${LIBCXX_OPTIONS[@]}" \
	"${LLVM_SOURCE}/runtimes" \
>>"$LOG_FILE";

log_end "LLVM runtime configure";

log_begin "LLVM runtime build";
build builtins cxx cxxabi unwind;
log_end "LLVM runtime build";

log_begin "LLVM runtime install";
install_ninja "${COMPILER_BUILTINS[@]}";
install "$SYSROOT_DIR" cxx cxx-headers cxx-modules cxxabi cxxabi-headers unwind unwind-headers;
log_end "LLVM runtime install";

mkdir -p "${INSTALL_RUNTIME_BASE}/licences";
cp -T "${LLVM_SOURCE}/libcxx/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/libc++.txt";
cp -T "${LLVM_SOURCE}/libcxxabi/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/libc++abi.txt";
cp -T "${LLVM_SOURCE}/libunwind/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/libunwind.txt";
cp -T "${LLVM_SOURCE}/compiler-rt/LICENSE.TXT" "${INSTALL_RUNTIME_BASE}/licences/compiler-rt.txt";

if [ "$BUILD_SANITIZERS" = ON ]
then
	INSTALL_SANITIZERS_DIR="$(install_dir sanitizers)";

	log_begin "LLVM sanitizers configure";

	mkcd "$LLVM_SANITIZERS_DIR";
	cmake -G Ninja \
		-Wno-dev \
		"${CMAKE_OPTIONS[@]}" \
		"${COMPILER_RT_OPTIONS[@]}" \
		"${LLVM_SOURCE}/compiler-rt" \
	>>"$LOG_FILE";

	log_end "LLVM sanitizers configure";

	log_begin "LLVM sanitizers build";
	if [ "$SYSTEM" = "lin" ]
	then
		build "${SANITIZERS_COMPONENTS[@]}";
	else
		build "${SANITIZERS[@]}";
	fi
	log_end "LLVM sanitizers build";
	
	log_begin "LLVM sanitizers install";
	install "${INSTALL_SANITIZERS_DIR}/resource" "${SANITIZERS_COMPONENTS[@]}";
	log_end "LLVM sanitizers install";

	mkdir -p "${INSTALL_SANITIZERS_DIR}/licences";
	cp -T "${LLVM_SOURCE}/compiler-rt/LICENSE.TXT" "${INSTALL_SANITIZERS_DIR}/licences/compiler-rt.txt";
fi

if [ "$BUILD_TYPE" = "runtime_test" ]
then
	log_begin "LLVM runtime tests";
	build check-runtimes;
	log_end "LLVM runtime tests";
fi