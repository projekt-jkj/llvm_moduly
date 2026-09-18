#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm_tools.sh";

log_header "LLVM";
mkcd "$LLVM_BUILD_DIR";

# -------------------
#    configuration
# -------------------

log_begin "LLVM configure";

cmake -G Ninja \
	-Wno-dev \
	"${CMAKE_OPTIONS[@]}" \
	"${LLVM_OPTIONS[@]}" \
	"${CLANG_OPTIONS[@]}" \
	"${LLD_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" \
>>"$LOG_FILE";

log_end "LLVM configure";

# -----------
#    build
# -----------

if [ "$BUILD_TYPE" = "llvm_test" ]
then
	log_begin "LLVM build";
	build_all;
	log_end "LLVM build";

	log_begin "LLVM tests";
	build check-all;
	log_end "LLVM tests";

	exit 1;
fi

for dist in "${DISTRIBUTIONS[@]}"
do
	log_begin "LLVM build $dist";
	build_distribution "$dist";
	log_end "LLVM build $dist";
done

if [ "$BUILD_TYPE" = "llvm_build" ]
then
	exit 1;
fi

# -----------------
#    instalation
# -----------------

log_begin "LLVM install";

for dist in "${DISTRIBUTIONS[@]}"
do
	install_distribution "$dist" "$INSTALL_TOOLS_BASE";
done

log_end "LLVM install";

if [ -v MSYS ]
then
	cd ../../..

	log_begin "LLVM MSYS dependencies";

	for dist in "${DISTRIBUTIONS[@]}"
	do
		./copy-msys-dependencies.sh "${INSTALL_TOOLS_BASE}/${dist}" "$MSYS" >>"$LOG_FILE";
	done

	log_end "LLVM MSYS dependencies";
fi