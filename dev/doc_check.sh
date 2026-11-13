#!/bin/bash
# shellcheck disable=SC1111

TRACKED_FILES=$(git ls-tree -r HEAD --name-only | grep ".*\.sh");

grep_check()
{
	what="$2";
	where="$1";
	grep -F "$what" "$where" >/dev/null \
	|| echo "File „$what“ NOT mentioned in „$where“.";
}
strip_arg()
{
	grep -o -- "-[^=)]*" | sort;
}
diff_check()
{
	check_header="$1";
	first_text_source="$2";
	second_text_source="$3";
	success="$4";
	failure="$5";

	echo "$check_header";

	diff \
		<(eval "$first_text_source") \
		<(eval "$second_text_source")  \
	&& printf "%s\n\n" "$success" \
	|| printf "\n%s\n\n" "$failure";
}

for doc_file in doc/info.*.txt
do
	echo "┌───────────────────┐";
	echo "│  $doc_file  │";
	echo "└───────────────────┘";
	echo;

	echo "=== $doc_file file check ===";
	for file in $TRACKED_FILES
	do
		grep_check "$doc_file" "$file";
	done
	echo

	SOURCE_ARGUMENT="^	-[^ =]*=\*)$";
	DOC_ARGUMENT="^-[^ =]*={}$";
	diff_check \
		"=== $doc_file argument check ===" \
		"grep \"$SOURCE_ARGUMENT\" argument_parser.sh | strip_arg" \
		"grep \"$DOC_ARGUMENT\" \"$doc_file\" | strip_arg" \
		"All arguments are documented consistently." \
		"Some arguments are NOT documented consistently.";

	SOURCE_ARGUMENT="^	-[^ =]*)$";
	DOC_ARGUMENT="^-[^ =]*$";
	diff_check \
		"=== $doc_file parametrized argument check ===" \
		"grep \"$SOURCE_ARGUMENT\" argument_parser.sh | strip_arg" \
		"grep \"$DOC_ARGUMENT\" \"$doc_file\" | strip_arg" \
		"All arguments are documented consistently." \
		"Some arguments are NOT documented consistently.";
done

echo "┌───────────────┐";
echo "│  CONSISTENCY  │";
echo "└───────────────┘";
echo;

ARGUMENT_OR_FILE="^(-[^ ]*|– [^ ]*\.sh)$";

diff_check \
		"=== Czech and English consistency ===" \
		"grep -E \"$ARGUMENT_OR_FILE\" doc/info.cs.txt" \
		"grep -E \"$ARGUMENT_OR_FILE\" doc/info.en.txt" \
		"Documented files and arguments order is consistent in both languages." \
		"Documented files and arguments order is NOT consistent in both languages.";

echo "=== Special char counts ===";
printf "\t(cs)\t(en)\n";

for char in  . ',' – + - '*' / = '(' ')' [ ] '{' '}' „ '“' '"' '`'
do
	count_cs=$(grep -o -F "$char" < "doc/info.cs.txt" | wc -c);
	count_en=$(grep -o -F "$char" < "doc/info.en.txt" | wc -c);
	echo "$char	$count_cs	$count_en";
done