#!/bin/bash


read_args_for_rep(){
	local count_arg_input=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--turn|-t)
			TURN="${2}"
			shift
			;;
		--row-num|-r)
			ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--input|-i)
			CONTENTS="${2}"
			shift
			;;
		-*)
			echo "no option: ${1}"
			exit 1
			;;
		*)	
			if [ ${count_arg_input} -eq 1  ];then
				REGEX_CON="${1:-}"
			elif [ ${count_arg_input} -eq 2 ]; then
				REPLACE_STR="${1:-}"
			fi
			count_arg_input=$((count_arg_input + 1))
			;;
	esac
	shift
	done <<- END
	$STR
	END
	if [ -p /dev/stdin ]; then
	    CONTENTS="$(cat)"
	fi
}

display_help_for_rep(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Rep"
				print ""
				print "Replace by line"
				print ""
				print "### ARG"
				print ""
				print "Arg"
				print ""
				print "#### first arg"
				print ""
				print "regex (default : blank)"
				print ""
				print "#### second arg (default : blank)"
				print ""
				print "replace str"
				print ""
				print "- Ex remove str"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku rep  \x22aa\x22"
				print ""
				print "->"
				print "\nbb"
				print "```"
				print ""
				print "- Ex replace string"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku rep  \x22(a)\x22 \x22PREFIX\\\\1SUFFIX\x22"
				print ""
				print "->"
				print "PREFIXaSUFFIXPREFIXaSUFFIX\nb"
				print "```"
				print ""
				print "### Option"
				print ""
				print "#### --input-i"
				print ""
				print "recieve input"
				print "```"
				print ""
				print "- Ex"
				print ""
				print "```.sh.sh"
				print "aku rep  \x22aa\x22 -i \x22aa\nbb\x22"
				print "->"
				print "\nbb"
				print "```"
				print ""
				print "#### --turn|-t"
				print ""
				print "- Ex"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku rep  \x22(a)\nb\x22 \x22\\\\1SUFFIX\x22 -t 1"
				print "->"
				print "aaSUFFIX\nbb"
				print "```"
				print ""
				print "- Ex range specify -end"
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku rep  \x22[a-z]\x22 -r -2"
				print "->"
				print "A\nB\nccC\nDdd"
				print "```"
				print ""
				print "- Ex range specify -start "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbwBb\nccC\nDdd\x22 | aku rep  \x22[a-z]x22 -r 2-"
				print "->"
				print "aaA\nB\nC\nD"
				print "```"
				print ""
				print "- Ex range specify start-end "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku rep  \x22[a-z]\x22 -r 2-4"
				print "->"
				print "aaA\nB\nC\nD"
				print "```"
				print ""
				print "- Ex multiple "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku rep  \x22[a-z]\x22 -r 1 -r 3-4"
				print "->"
				print "A\nbBb\ncC\nD"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_rep(){
	local contain_num_separator=","
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
		-v src_con="${CONTENTS}" \
	 	-v TURN="${TURN}}" \
	 	-v ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
	 	-v REGEX_CON="${REGEX_CON}"\
	 	-v REPLACE_STR="${REPLACE_STR}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
		'BEGIN{
			max_lines = split(src_con, _line_array, "\n")
			# print "CONTAIN_NUM_SEPARATOR "CONTAIN_NUM_SEPARATOR
			DISPLAY_ROW_NUM_CON = make_list_from_muti_list_con(\
				ROW_NUM_LIST_CON, \
				max_lines,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
			gsub(CONTAIN_NUM_SEPARATOR, "", ROW_NUM_LIST_CON)
			# print "ROW_NUM_LIST_CON "ROW_NUM_LIST_CON
			# print "DISPLAY_ROW_NUM_CON "DISPLAY_ROW_NUM_CON

			last_output = ""
		}
	{
		# print "## "$0
		# print "DISPLAY_ROW_NUM_CON "DISPLAY_ROW_NUM_CON
		match_row_num = sprintf("%s%s%s", CONTAIN_NUM_SEPARATOR, NR, CONTAIN_NUM_SEPARATOR)
		if(\
			index(\
				sprintf(\
					"%s%s%s",\
					CONTAIN_NUM_SEPARATOR,\
					DISPLAY_ROW_NUM_CON,\
					CONTAIN_NUM_SEPARATOR\
				),\
				match_row_num\
			) == 0\
			&& DISPLAY_ROW_NUM_CON\
		){
			print $0
			next
		}
		print gensub(REGEX_CON, REPLACE_STR, TURN, $0)
	}'
}
