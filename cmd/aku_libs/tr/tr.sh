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
			TURN="${2}"
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
				print "Trace contents"
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
				print "echo \x22aa\nbb\x22 | aku tr"
				print ""
				print "->"
				print "aabb"
				print ""
				print "- Ex replace string"
				print ""
				print "echo \x22aa\nbb\x22 | aku tr \x22(a)\nb\x22 \x22\\\\1NEWLINE\x22"
				print ""
				print "->"
				print "aNEWLINEb"
				print ""
				print "### Option"
				print ""
				print "#### --input-i"
				print ""
				print "recieve input"
				print ""
				print "- Ex"
				print ""
				print "aku tr \x22aa\x22 -i \x22aabb\x22"
				print "->"
				print "bb"
				print ""
				print "#### --turn|-t"
				print ""
				print "- Ex"
				print ""
				print "echo \x22aa\nbb\x22 | aku tr \x22(a)\nb\x22 \x22\\\\1NEWLINE\x22 -t "
				print "->"
				print "aNEWLINEb"
				print ""
				print "- Ex range specify -end"
				print ""
				print "echo \x22aa\nbb\ncc\ndd\x22 | aku tr -t -2"
				print "->"
				print "aabbcc\ndd"
				print ""
				print "- Ex range specify -start "
				print ""
				print "echo \x22aa\nbb\ncc\ndd\x22 | aku tr -t 2-"
				print "->"
				print "aa\nbbccdd"
				print ""
				print "- Ex range specify start-end "
				print ""
				print "echo \x22aa\nbb\ncc\ndd\x22 | aku tr -t 2-4"
				print "->"
				print "aa\nbbccdd"
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
		-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
		-v CONTENTS="${CONTENTS}"\
		-v REGEX_CON="${REGEX_CON}"\
		-v REPLACE_STR="${REPLACE_STR}"\
		-v TURN="${TURN}"\
	'function convert_nums_by_compa(nums_con, max_num){
			output = ""
			if (\
				nums_con ~ /^0$/\
				|| !nums_con\
			) {
				for (i = 1; i <= max_num; i++) {
				    output = sprintf("%s%s%s", output,CONTAIN_NUM_SEPARATOR, i)
				}
				return output
			}
			if( nums_con ~ /^[0-9]+$/ ){
		  		return sprintf("%s%s", nums_con, CONTAIN_NUM_SEPARATOR)
			}
			if (nums_con ~ /^-[0-9]+$/) {
			    split(nums_con, parts, "-")
			    start = 1 
			    end = parts[2]
			    for (i = int(start); i <= int(end); i++) {
			        output = sprintf("%s%s%s", output, CONTAIN_NUM_SEPARATOR, i)
			    }
			    return output
			  }
			if (nums_con ~ /^[0-9]+-[0-9]+$/) {
			    split(nums_con, parts, "-")
			    start = parts[1]
			    end = parts[2]
			    for (i = int(start); i <= int(end); i++) {
			        output = sprintf("%s%s%s", output, CONTAIN_NUM_SEPARATOR, i)
			    }
			    return output
			  }
			if (nums_con ~ /^[0-9]+-$/) {
				start = substr(nums_con, 1, length(nums_con) - 1)
				for (i = int(start); i <= max_num; i++) {
				    output = sprintf("%s%s%s", output,CONTAIN_NUM_SEPARATOR, i)
				}
				return output
			}
		  	printf( "contain no number in --field-num|-f arg: %s\n", nums_con) > "/dev/stderr"
		  	exit 1 
		}

	BEGIN{
		# print "TURN "TURN
		if(TURN == "g"){
			print gensub(REGEX_CON, REPLACE_STR, TURN, CONTENTS)
			exit
		}
		turn_list_con = convert_nums_by_compa(TURN, length(CONTENTS))
		# print "turn_list_con " turn_list_con
		CONTAIN_NUM_SEPARATOR_PREFIX_REGEX = "^"CONTAIN_NUM_SEPARATOR
		CONTAIN_NUM_SEPARATOR_SUFFIX_REGEX = CONTAIN_NUM_SEPARATOR"$"
		CONTAIN_NUM_SEPARATOR_CONSEC_REGEX = sprintf("[%s]+", CONTAIN_NUM_SEPARATOR)
		gsub(CONTAIN_NUM_SEPARATOR_PREFIX_REGEX, "", turn_list_con)
		gsub(CONTAIN_NUM_SEPARATOR_SUFFIX_REGEX, "", turn_list_con)
		gsub(CONTAIN_NUM_SEPARATOR_CONSEC_REGEX, CONTAIN_NUM_SEPARATOR, turn_list_con)
		turn_list_len = split(turn_list_con, turn_list, CONTAIN_NUM_SEPARATOR)
		result_contents = CONTENTS
		rep_count = 0
		for (l=1; l <= turn_list_len; l++){
			# print "## l "l
			# print "result_contents "result_contents
			rep_order = l - rep_count
			result_contents = gensub(REGEX_CON, REPLACE_STR, rep_order, result_contents)
			# print "result_contents11 " result_contents
			rep_count++
		}
		# print "##"
		print result_contents
	}'
}
