#!/bin/bash


read_args_for_tr(){
	local count_arg_input=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--input|-i)
			CONTENTS="${2}"
			shift
			;;
		--turn|-t)
			case "${TURN_LIST_CON}" in
				"g") TURN_LIST_CON=""
					;;
			esac
			TURN_LIST_CON="${TURN_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		-*)
			echo "no option: ${1}"
			exit 1
			;;
		*)	
			if [ ${count_arg_input} -eq 1  ];then
				REGEX_CON="${1:-}"
			elif [ ${count_arg_input} -ge 2 ]; then
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

display_help_for_tr(){
	case "${HELP}" in
		"")
			;;
		*)
			awk 'BEGIN {
				print "## Tr"
				print ""
				print "Total replace"
				print ""
				print "### ARG"
				print ""
				print "Arg"
				print ""
				print "#### first arg"
				print ""
				print "regex (default : newline)"
				print ""
				print "#### second arg (default : blank)"
				print ""
				print "replace str"
				print ""
				print "- Ex remove newline"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku tr"
				print ""
				print "->"
				print "aabb"
				print "```"
				print ""
				print "- Ex replace string"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku tr \x22(a)\nb\x22 \x22\\\\1NEWLINE\x22"
				print ""
				print "->"
				print "aNEWLINEb"
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
				print "aku tr \x22aa\x22 -i \x22aabb\x22"
				print "->"
				print "bb"
				print "```"
				print ""
				print "#### --turn|-t"
				print ""
				print "- Ex"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku tr \x22(a)\nb\x22 \x22\\\\1NEWLINE\x22 -t "
				print "->"
				print "aNEWLINEb"
				print "```"
				print ""
				print "- Ex range specify -end"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\ncc\ndd\x22 | aku tr -t -2"
				print "->"
				print "aabbcc\ndd"
				print "```"
				print ""
				print "- Ex range specify -start "
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\ncc\ndd\x22 | aku tr -t 2-"
				print "->"
				print "aa\nbbccdd"
				print "```"
				print ""
				print "- Ex range specify start-end "
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\ncc\ndd\x22 | aku tr -t 2-4"
				print "->"
				print "aa\nbbccdd"
				print "```"
				print ""
				print "- Ex multiple "
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku tr -t 1-2 -t 4-5"
				print "->"
				print "aabbcc\nddeeff"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}

exec_tr(){
	local contain_num_separator=","
	# echo "REGEX_CON: ${REGEX_CON}"
	# echo "REPLACE_STR: ${REPLACE_STR}"

	${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
		-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
		-v CONTENTS="${CONTENTS}"\
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
		-v REGEX_CON="${REGEX_CON}"\
		-v REPLACE_STR="${REPLACE_STR}"\
		-v TURN_LIST_CON="${TURN_LIST_CON#${NUM_LIST_CON_SEPARATOR}}"\
	'
	BEGIN{
		# print "## TURN_LIST_CON "TURN_LIST_CON
		if(TURN_LIST_CON ~ /g/){
			print gensub(REGEX_CON, REPLACE_STR, TURN_LIST_CON, CONTENTS)
			exit
		}
		turn_list_con = make_list_from_muti_list_con(TURN_LIST_CON, length(CONTENTS), NUM_LIST_CON_SEPARATOR, CONTAIN_NUM_SEPARATOR)
		# turn_list_con = convert_nums_by_compa(TURN_LIST_CON, length(CONTENTS), CONTAIN_NUM_SEPARATOR)
		# print "turn_list_con " turn_list_con
		turn_list_con = trim_separator(turn_list_con, CONTAIN_NUM_SEPARATOR)
		# print "00 turn_list_con " turn_list_con
		turn_list_con = sort_list_con(turn_list_con, CONTAIN_NUM_SEPARATOR)
		# print "11 turn_list_con " turn_list_con
		turn_list_con = remove_dup_el(turn_list_con, CONTAIN_NUM_SEPARATOR)

		# print "## turn_list_con "turn_list_con
		turn_list_len = split(turn_list_con, turn_list, CONTAIN_NUM_SEPARATOR)
		result_contents = CONTENTS
		rep_count = 0
		for (l=1; l <= turn_list_len; l++){
			# print "## l "l
			cur_num = turn_list[l]
			# print "result_contents "result_contents
			# print "cur_num "cur_num
			# print "rep_count "rep_count
			rep_order = cur_num - rep_count
			# print "rep_order "rep_order
			result_contents = gensub(REGEX_CON, REPLACE_STR, rep_order, result_contents)
			# print "result_contents11 " result_contents
			rep_count++
		}
		# print "##"
		print result_contents
	}'
}
