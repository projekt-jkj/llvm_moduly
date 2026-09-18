#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "argument_parser.sh";
source "helpers.sh";
source "./options/llvm_libraries.sh";

log_header "LLVM libraries";
mkcd "$LLVM_LIBRARIES_DIR";

# -------------------
#    configuration
# -------------------

log_begin "LLVM libraries configure";

cmake -G Ninja \
	-Wno-dev \
	"${CMAKE_OPTIONS[@]}" \
	"${LLVM_OPTIONS[@]}" \
	"${CLANG_OPTIONS[@]}" \
	"${LIBCLANG_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" \
>>"$LOG_FILE";

log_end "LLVM libraries configure";

# -----------
#    build
# -----------

if [ "$BUILD_TYPE" = "libraries_test" ]
then
	log_begin "LLVM libraries build";
	build_all;
	log_end "LLVM libraries build";

	log_begin "LLVM libraries tests";
	build check-all;
	log_end "LLVM libraries tests";

	exit 1;
fi

for dist in "${DISTRIBUTIONS[@]}"
do
	log_begin "LLVM libraries build $dist";
	build_distribution "$dist";
	log_end "LLVM libraries build $dist";
done

if [ "$BUILD_TYPE" = "libraries_build" ]
then
	exit 1;
fi

# -----------------
#    instalation
# -----------------

log_begin "LLVM libraries install";

for dist in "${DISTRIBUTIONS[@]}"
do
	install_distribution "$dist" "$INSTALL_LIBRARIES_BASE";
done

log_end "LLVM libraries install";