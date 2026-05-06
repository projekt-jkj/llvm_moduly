# LLVM variables

LLVM_MODULY_VERSION="${LLVM_MODULY_VERSION:-22.1.5}";
LLVM_TAG="${LLVM_TAG:-llvmorg-$LLVM_MODULY_VERSION}";
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

if [ -v INSTALL_PREFIX ]
then
	INSTALL_BASE="${INSTALL_PREFIX}/install_$LLVM_MODULY_VERSION";
else
	INSTALL_BASE="$(pwd)/install_$LLVM_MODULY_VERSION";
fi

# platforms

join()
{
	local out=$1;
	local IFS=";";
	shift;

	declare -g "$out=$*"
}

if [ -v ARCHITECTURES ]
then
	readarray -d "," -t arch_list <<< "$ARCHITECTURES";
	llvm_archs_list=();
	for arch in "${arch_list[@]}"
	do
		case ${arch,,} in
			x86|x64|amd64)
				llvm_archs_list+=("X86");
				;;
			*)
				llvm_archs_list+=("$arch");
				;;
		esac
	done
	join LLVM_ARCHITECTURES "${llvm_archs_list[@]}";
else
	LLVM_ARCHITECTURES="host";
fi

# other variables

ROOT=$(pwd);
LOG_FILE="${LOG_FILE:-/dev/null}";

log_begin()
{
	echo "=== [$1] $(date '+%H:%M:%S') ===" | tee -a "$LOG_FILE";
}
log_ok()
{
	echo "=== [$1] OK ===" | tee -a "$LOG_FILE";
}