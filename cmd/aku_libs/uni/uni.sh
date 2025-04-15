#!/bin/bash


read_args_for_uni(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--bound-str|-b)
			BOUND_STR="${2}"	
			shift
			;;
		-*)
			echo "no option: ${1}"
			exit 1
			;;
		*)	
			if [ ${is_already_first_con} -gt 0 ];then
				CONTENTS="${CONTENTS}${VAL_LIST_CON_SEPARATOR}${1:-}"
			fi
			is_already_first_con=1
			;;
	esac
	shift
	done <<- END
	$STR
	END
}

display_help_for_uni(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Uni"
				print ""
				print "Union variables"
				print ""
				print "### ARG"
				print ""
				print "Arg"
				print ""
				print "- Ex two arg"
				print ""
				print "```sh.sh"
				print "aku uni \x22aa\x22 \x22bb\x22"
				print "->"
				print "aa\nbb"
				print "```"
				print ""
				print "- Ex multiple arg"
				print ""
				print "```sh.sh"
				print "aku uni \x22aa\x22 \x22bb\x22 \x22cc\x22..."
				print "->"
				print "aa\nbb\ncc\n..."
				print "```"
				print ""
				print "### Option"
				print ""
				print "#### --bound-str|-b"
				print ""
				print "union by bound str (default: newline)"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku uni \x22aa\x22 \x22bb\x22 -b \x22\\n---\x22"
				print "->"
				print "aa\n---bb"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_uni(){
	${AWK_PATH} \
		-v CONTENTS="${CONTENTS#${VAL_LIST_CON_SEPARATOR}}"\
		-v BOUND_STR="${BOUND_STR}"\
		-v VAL_LIST_CON_SEPARATOR="${VAL_LIST_CON_SEPARATOR}"\
		'BEGIN{
			print gensub(\
				VAL_LIST_CON_SEPARATOR, \
				BOUND_STR, \
				"g",
				CONTENTS\
			)
		}'
}	
