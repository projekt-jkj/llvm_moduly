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

	targets=();
	for t in "$@"
	do
		targets+=("install-$t-stripped");
	done

	reset_dir "$INSTALL_BASE/tmp";
	ninja "${targets[@]}" "-j$CORES" >>"$LOG_FILE";
	mkdir -p "$INSTALL_BASE/$where";
	cp -rf "$INSTALL_BASE"/tmp/* "$INSTALL_BASE/$where";
}
install_distribution()
{
	reset_dir "$INSTALL_BASE/tmp";
	ninja "install-$1-distribution-stripped" "-j$CORES" >>"$LOG_FILE";
	mkdir -p "$INSTALL_BASE/$1";
	cp -rf "$INSTALL_BASE"/tmp/* "$INSTALL_BASE/$1";
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