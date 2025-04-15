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
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
		-v REGEX_CON="${REGEX_CON}"\
		-v REPLACE_STR="${REPLACE_STR}"\
		-v TURN_LIST_CON="${TURN_LIST_CON#${NUM_LIST_CON_SEPARATOR}}"\
	'function convert_nums_by_compa(nums_con, max_num, separator){
			output = ""
			if (\
				nums_con ~ /^0$/\
				|| !nums_con\
			) {
				for (i = 1; i <= max_num; i++) {
				    output = sprintf("%s%s%s", output,separator, i)
				}
				return output
			}
			if( nums_con ~ /^[0-9]+$/ ){
		  		return sprintf("%s%s", nums_con, separator)
			}
			if (nums_con ~ /^-[0-9]+$/) {
			    split(nums_con, parts, "-")
			    start = 1 
			    end = parts[2]
			    for (i = int(start); i <= int(end); i++) {
			        output = sprintf("%s%s%s", output, separator, i)
			    }
			    return output
			  }
			if (nums_con ~ /^[0-9]+-[0-9]+$/) {
			    split(nums_con, parts, "-")
			    start = parts[1]
			    end = parts[2]
			    for (i = int(start); i <= int(end); i++) {
			        output = sprintf("%s%s%s", output, separator, i)
			    }
			    return output
			  }
			if (nums_con ~ /^[0-9]+-$/) {
				start = substr(nums_con, 1, length(nums_con) - 1)
				for (i = int(start); i <= max_num; i++) {
				    output = sprintf("%s%s%s", output,separator, i)
				}
				return output
			}
		  	printf( "contain no number in --field-num|-f arg: %s\n", nums_con) > "/dev/stderr"
		  	exit 1 
		}
		function sort_list_con(list_con, separator) {
		  # 配列を値で数値として昇順にソート (GNU awk拡張)
			list_len = split(list_con, list, separator)
			new_list_con = ""
			PROCINFO["sorted_in"] = "@val_num_asc"
			for (i in list) {
				el = list[i]
				if(!new_list_con){
					new_list_con = el
					continue
				}
				new_list_con = sprintf("%s%s%s", new_list_con, separator, el)
			}
			PROCINFO["sorted_in"] = ""
			return new_list_con
		}
		function trim_separator(list_con, separator){
			contain_num_separator_prefix_regex = "^"separator
			contain_num_separator_suffix_regex = separator"$"
			contain_num_separator_consec_regex = sprintf("[%s]+", separator)
			gsub(contain_num_separator_prefix_regex, "", list_con)
			gsub(contain_num_separator_suffix_regex, "", list_con)
			gsub(contain_num_separator_consec_regex, separator, list_con)
			return list_con
		}
		function remove_dup_el(list_con,  separator) {
		  list_len = split(list_con, list, separator)
		  new_list_con = "" 
		  for (i in list) {
		  	el = list[i]
		  	# print "el "el
		    if (seen[el]) continue 
		    seen[el]++
		  	if(!new_list_con){
		  		new_list_con = el
		  		continue
		  	}
		  	new_list_con = sprintf("%s%s%s", new_list_con, separator, el)
		  }
		  delete seen # seen配列を削除。
		  return new_list_con
		}
		function make_list_from_muti_list_con(lists_con, max_num, list_separator, el_separator){
			lists_len = split(lists_con, list, list_separator)
			new_list_con = ""
			for(l=1; l <= lists_len; l++){
				el = list[l]
				new_list_con = sprintf(\
					"%s%s%s",
					new_list_con,\
					separator,
					convert_nums_by_compa(el, max_num, el_separator))
			}
			consec_separator_regex = separator"+"
			gsub(consec_separator_regex, consec_separator_regex, new_list_con)
			return new_list_con
		}
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
