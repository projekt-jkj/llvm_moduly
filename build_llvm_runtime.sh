#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm_runtime.sh";

log_begin "LLVM runtime";
mkcd "$LLVM_BUILTINS_DIR";

cmake -G Ninja \
	"${CMAKE_OPTIONS[@]}" \
	"${BUILTINS_OPTIONS[@]}" \
	"${LLVM_SOURCE}/compiler-rt/lib/builtins" >>"$LOG_FILE";

log_ok "LLVM builtins configure";

build builtins;
log_ok "LLVM builtins build";

install llvm_clang builtins;
log_ok "LLVM builtins install";

mkcd "$LLVM_RUNTIME_DIR";
cmake -G Ninja \
	"-DLLVM_ENABLE_RUNTIMES=libunwind;libcxxabi;libcxx" \
	"${CMAKE_OPTIONS[@]}" \
	"${LIBUNWIND_OPTIONS[@]}" \
	"${LIBCXX_ABI_OPTIONS[@]}" \
	"${LIBCXX_OPTIONS[@]}" \
	"${LLVM_SOURCE}/runtimes" >>"$LOG_FILE";

log_ok "LLVM runtime configure";

build_all;
log_ok "LLVM runtime build";

install_all llvm_clang;
log_ok "LLVM runtime install";