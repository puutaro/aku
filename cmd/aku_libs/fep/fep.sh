#!/bin/bash


read_args_for_fep(){
	local count_arg_input=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--field-num-to-delete-regex|-f)
			FIELD_NUM_TO_REMOVE_REGEX_CON="${2}"
			shift
			;;
		--field-num-to-str|-s)
			FIELD_NUM_TO_STR_CON="${2}"
			shift
			;;
		--delimitter|-d)
			DELIMITTER="${2}"
			shift
			;;
		--output-delimiter|-o)
			OUTPUT_DELIMITER="${2}"
			shift
			;;
		--row-num|-r)
			ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--turn|-t)
			TURN="${2}"
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
				FIELD_NUM_TO_REMOVE_REGEX_CON="${1:-}"
			elif [ ${count_arg_input} -ge 2 ]; then
				FIELD_NUM_TO_STR_CON="${FIELD_NUM_TO_STR_CON} ${1:-}"
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
	elif [ -f "${CONTENTS}" ];then
		CONTENTS="$(cat "${CONTENTS}")"
	fi
	case "${OUTPUT_DELIMITER}" in
		"") OUTPUT_DELIMITER="${DELIMITTER}"
			;;
	esac
	case "${TURN}" in
		"") TURN="g"
			;;
	esac
}

display_help_for_fep(){
	case "${HELP}" in
		"")
			;;
		*)
			awk 'BEGIN {
				print "## Fep"
				print ""
				print "Replace field"
				print ""
				print "### ARG"
				print ""
				print "Arg or stdin"
				print ""
				print "#### first arg"
				print ""
				print "target field to remove regex"
				print ""
				print "- format -> fieild num:regex"
				print ""
				print "- Ex1 single field"
				print ""
				print "```sh.sh"
				print "echo \x22aa1 bb cc #dd\x22 | aku fep \x221:^aa\x22"
				print ""
				print "->"
				print "1 bb cc #dd"
				print "```"
				print ""
				print "- Ex3 by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep \x22-4:^[a-z]\x22"
				print ""
				print "->"
				print "a b c #dd"
				print "```"
				print ""
				print "- Ex4 by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep \x222-:^[a-z]\x22"
				print ""
				print "->"
				print "aa b c #dd"
				print "```"
				print ""
				print "#### second arg"
				print ""
				print "- format -> fieild num:regex"
				print ""
				print "replace first arg field to str with remove regex"
				print ""
				print "- Ex1 single field"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep \x221:^[a-z]\x22 \x221:CC\x22"
				print ""
				print "->"
				print "CCa bb cc #dd"
				print "```"
				print ""
				print "- Ex2 by range"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep \x222-:^[a-z]\x22 \x223-4:CC\x22"
				print ""
				print "->"
				print "aa b CCc #dd"
				print "```"
				print ""
				print "- Ex3 by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep \x222:^[a-z]\x22 \x22-4:CC\x22"
				print ""
				print "->"
				print "aa UUb cc #dd"
				print "```"
				print ""
				print "- Ex4 by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep \x223:[a-z]$\x22 \x222-:TTx22"
				print ""
				print "->"
				print "aa bb cTT #dd"
				print "```"
				print ""
				print "### Option"
				print ""
				print "#### --row-num|-r"
				print ""
				print "target row (default: all)"
				print ""
				print "- Ex1 single row"
				print ""
				print "```sh.sh"
				print "echo ~\x22 | aku fep -r \x2221\x22"
				print "```"
				print ""
				print "- Ex2 multiple row"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku fep -r \x221\x22 -r \x223-4\x22"
				print "```"
				print ""
				print "- Ex3 multiple row by end range"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku fep -r \x221\x22 -r \x22-4\x22"
				print "```"
				print ""
				print "#### --delimitter|-d"
				print ""
				print "delimitter (default is space)"
				print ""
				print "- Ex string delimitter"
				print ""
				print "```sh.sh"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku fep -f \x222:bb\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "aaAAAbbAAAccAAA#dd"
				print "```"
				print ""
				print "#### --output-delimiter|-o"
				print ""
				print "output delimiter (deafult is delimiter)"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo \x22aa  bb     cc      #dd\x22 | aku fep -o \x22\t\x22"
				print ""
				print "->"
				print "bb cc"
				print "```"
				print ""
				print "#### --turn|-t"
				print ""
				print "gnu awk gensub third parameter"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo \x22aa bb cc #dd\x22 | aku fep -f \x221:B\x22 -t \x221\x22"
				print ""
				print "->"
				print "Ba bb cc #dd"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}

exec_fep(){
	# echo "FIELD_NUM_TO_REMOVE_REGEX_CON: ${FIELD_NUM_TO_REMOVE_REGEX_CON}"
	# echo "FIELD_NUM_TO_STR_CON: ${FIELD_NUM_TO_STR_CON# }END"
	# exit 0
	local max_lines=$(\
		echo "${CONTENTS}"\
			| awk '{nr_count++}
			END {print nr_count}'\
	)
	local contain_num_separator=","
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
		-i "${AWK_LINE_FUNCS_PATH}"\
		-F "${DELIMITTER}" \
		-v max_lines="${max_lines}"\
	 	-v FIELD_NUM_TO_REMOVE_REGEX_CON="${FIELD_NUM_TO_REMOVE_REGEX_CON}" \
	 	-v FIELD_NUM_TO_STR_CON="${FIELD_NUM_TO_STR_CON# }" \
	 	-v OUTPUT_DELIMITER="${OUTPUT_DELIMITER}"\
	 	-v TURN="${TURN}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v NUM_REGEX_SEPARATOR="${NUM_REGEX_SEPARATOR}"\
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
	 	-v ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v max_nf_num="${max_nf_num}" \
		'BEGIN{
			DISPLAY_FIELD_NUM_CON = ""
			FIELD_NUM_TO_REMOVE_REGEX_MAP[0] = ""

			field_num_con ="" 
			regex_con ="" 
			colonPos = index(FIELD_NUM_TO_REMOVE_REGEX_CON, NUM_REGEX_SEPARATOR) # 最初のコロンの位置を取得
			if(\
				FIELD_NUM_TO_REMOVE_REGEX_CON \
				&& colonPos == 0\
			) {
				print "field num or regex not found: "FIELD_NUM_TO_REMOVE_REGEX_CON > "/dev/stderr"
				exit 1
			}
			field_num_con = substr(FIELD_NUM_TO_REMOVE_REGEX_CON, 1, colonPos - 1)
			regex_con = substr(FIELD_NUM_TO_REMOVE_REGEX_CON, colonPos + 1) # コロンの次の文字から最後までを抽出
			nums_by_coma = convert_nums_by_compa(field_num_con, max_nf_num, CONTAIN_NUM_SEPARATOR)
			DISPLAY_FIELD_NUM_CON = sprintf(\
				"%s%s",
				CONTAIN_NUM_SEPARATOR,
				nums_by_coma)
			nums_list_len = split(nums_by_coma, nums_list, CONTAIN_NUM_SEPARATOR)
			for(j=1;j<=nums_list_len;j++){
				cur_num = nums_list[j]
				if(cur_num !~ /^[0-9]+$/)	 continue
				cur_filed_num_to_regex = FIELD_NUM_TO_REMOVE_REGEX_MAP[cur_num]
				if(!cur_filed_num_to_regex){
					FIELD_NUM_TO_REMOVE_REGEX_MAP[cur_num] = regex_con
					continue
				}
				FIELD_NUM_TO_REMOVE_REGEX_MAP[cur_num] = sprintf(\
					"%s%s%s",\
					cur_filed_num_to_regex,\
					NUM_LIST_CON_SEPARATOR,\
					regex_con\
				)
			}

			FIELD_NUM_TO_STR_MAP[0] = ""
			field_num_con ="" 
			str_list_con ="" 
			colonPos = index(FIELD_NUM_TO_STR_CON, NUM_REGEX_SEPARATOR) # 最初のコロンの位置を取得
			if(\
				FIELD_NUM_TO_STR_CON \
				&& colonPos == 0\
			) {
				print "field num or str not found: "FIELD_NUM_TO_STR_CON > "/dev/stderr"
				exit 1
			}
			field_num_con = substr(FIELD_NUM_TO_STR_CON, 1, colonPos - 1)
			str_list_con = substr(FIELD_NUM_TO_STR_CON, colonPos + 1) # コロンの次の文字から最後までを抽出
			nums_by_coma = convert_nums_by_compa(field_num_con, max_nf_num, CONTAIN_NUM_SEPARATOR)
			STR_FIELD_NUM_CON = sprintf(\
				"%s%s",
				CONTAIN_NUM_SEPARATOR,
				nums_by_coma)
			nums_list_len = split(nums_by_coma, nums_list, CONTAIN_NUM_SEPARATOR)
			for(j=1;j<=nums_list_len;j++){
				cur_num = nums_list[j]
				if(cur_num !~ /^[0-9]+$/)	 continue
				cur_filed_num_to_regex = FIELD_NUM_TO_STR_MAP[cur_num]
				if(!cur_filed_num_to_regex){
					FIELD_NUM_TO_STR_MAP[cur_num] = str_list_con
					continue
				}
				FIELD_NUM_TO_STR_MAP[cur_num] = sprintf(\
					"%s%s%s",\
					cur_filed_num_to_regex,\
					NUM_LIST_CON_SEPARATOR,\
					str_list_con\
				)
			}
			max_lines = split(SRC_CON, _line_array, "\n")
			# print "CONTAIN_NUM_SEPARATOR "CONTAIN_NUM_SEPARATOR

			# print "max_lines "max_lines
			# print "ROW_NUM_LIST_CON "ROW_NUM_LIST_CON
			DISPLAY_ROW_NUM_CON = make_list_from_muti_list_con(\
				ROW_NUM_LIST_CON, \
				max_lines,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
			DISPLAY_ROW_NUM_CON = trim_separator(DISPLAY_ROW_NUM_CON, CONTAIN_NUM_SEPARATOR)
			DISPLAY_ROW_NUM_CON = sort_list_con(DISPLAY_ROW_NUM_CON, CONTAIN_NUM_SEPARATOR)
			DISPLAY_ROW_NUM_CON = remove_dup_el(DISPLAY_ROW_NUM_CON, CONTAIN_NUM_SEPARATOR)
			# print "DISPLAY_ROW_NUM_CON "DISPLAY_ROW_NUM_CON
			last_output = ""
		}
	{
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
			# print "NR "NR
			new_line =""
			for(l = 1; l<=NF; l++){
				# print "l; "l" "$l
				new_line = make_line_by_delimiter(new_line, $l, OUTPUT_DELIMITER)
			}
			# print "OUTPUT_DELIMITER "OUTPUT_DELIMITER"AA"
			# print "new_line "new_line
			last_output = make_line_by_delimiter(last_output, new_line, "\n")
			next
		}
		line = ""
		for(l=1;l<=NF;l++){
			match_field_num = sprintf("%s%s%s", CONTAIN_NUM_SEPARATOR, l, CONTAIN_NUM_SEPARATOR)
			if(\
				index(\
					sprintf(\
						"%s%s%s", \
						CONTAIN_NUM_SEPARATOR,\
						DISPLAY_FIELD_NUM_CON,\
						CONTAIN_NUM_SEPARATOR\
					), 
					match_field_num)  == 0\
				&& DISPLAY_FIELD_NUM_CON\
			) {
				line = make_line_by_delimiter(line, $l, OUTPUT_DELIMITER)
				continue
			}
			cur_regex = FIELD_NUM_TO_REMOVE_REGEX_MAP[l]
			cur_str = FIELD_NUM_TO_STR_MAP[l]
			$l = gensub(cur_regex, cur_str, TURN, $l)
			line = make_line_by_delimiter(line, $l, OUTPUT_DELIMITER)
		}
		last_output = make_line_by_delimiter(last_output, line, "\n")
	}
	END {
		regex_last_delmiter = sprintf("%s$", OUTPUT_DELIMITER)
		gsub(regex_last_delmiter, "", last_output)
		print last_output
	}'
}
