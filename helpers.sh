# shellcheck shell=bash
# shellcheck disable=SC2034

mkcd()
{
	mkdir -p "$1";
    cd "$1" || exit 1;
}
join()
{
	local IFS=";";
	echo "$*";
}
reset_dir()
{
	rm -rf "$1";
	mkdir -p "$1";
}
path_conversion()
{
	case "$(uname -s)" in
		MSYS*|MINGW*)
			cygpath -w "$1" ;;
		*)
			echo "$1" ;;
	esac
}

# -------------------
#    ninja helpers
# -------------------

build()
{
	ninja "-j$CORES" "$@" >>"$LOG_FILE";
}
build_all()
{
	ninja "-j$CORES" >>"$LOG_FILE";
}
build_distribution()
{
	ninja "$1-distribution"  "-j$CORES" >>"$LOG_FILE";
}

install()
{
	where="$1";
	shift;

	for c in "$@"
	do
		cmake --install . \
			--prefix "$where" \
			--strip \
			--component "$c" \
		>>"$LOG_FILE";
	done
}
install_ninja()
{
	targets=();
	for t in "$@"
	do
		targets+=("install-$t-stripped");
	done

	ninja "${targets[@]}" >>"$LOG_FILE";
}

#shellcheck disable=SC1087
#shellcheck disable=SC2154
install_distribution()
{
	local dist="$1";
	local dist_install_path="$INSTALL_TOOLS_BASE/$dist"

	eval "local components=(\"\${${dist@U}[@]}\")";

	for c in "${components[@]}"
	do
		cmake --install . \
			--prefix "$dist_install_path" \
			--strip \
			--component "$c" \
		>>"$LOG_FILE";
	done

	mkdir -p "$dist_install_path/licences";
	cp -T "${LLVM_SOURCE}/LICENSE.TXT" "$dist_install_path/licences/llvm.txt";
}

# ---------------------
#    logging helpers
# ---------------------

log_begin()
{
	echo "=== [$1] $(date '+%H:%M:%S') ===" | tee -a "$LOG_FILE";
}
log_ok()
{
	echo "=== [$1] OK ===" | tee -a "$LOG_FILE";
}