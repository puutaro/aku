#!/bin/bash


read_args_for_apl(){
	local count_arg_input=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--field-num|-f)
			FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		---delimitter|-d)
			DELIMITTER="${2}"
			shift
			;;
		-if|-i)
			REGEX_CON="${2}"
			shift
			;;
		-row-num|-r)
			ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--on-negative|-n)
			ON_NEGATIVE="on"
			;;
		-*)
			echo "no option: ${1}"
			exit 1
			;;
		*)	
			case ${count_arg_input} in
				1)
					CMD_CON="${1:-}"
					;;
			esac
			count_arg_input=$((count_arg_input + 1))
			;;
	esac
	shift
	done <<- END
	$STR
	END
	if [ -p /dev/stdin ]; then
	    CONTENTS="$(cat)"
	elif [ -z "${HELP}" ]; then
		echo "no stdin" 1>&2
		exit 1
	fi
	if [ -z "${HELP}" ] \
		&& [ -z "${REGEX_CON}" ];then
		echo "first arg (match regex) not exist"
		exit 1
	fi
	if [ -z "${HELP}" ] \
		&& [ -z "${CMD_CON}" ];then
		echo "second arg (cmd) not exist"
		exit 1
	fi
}

display_help_for_apl(){
	case "${HELP}" in
		"")
			;;
		*)
			awk 'BEGIN {
				print "## Apl"
				print ""
				print "Apply cmd to field or row in pipe"
				print ""
				print "### ARG"
				print ""
				print "Arg"
				print ""
				print "#### first arg"
				print ""
				print "proc cmd"
				print ""
				print "- default first cmd: echo \x22${0}\x22"
				print ""
				print "- @{0}, @{1}, @{2}.. to $0, $1, $2..  in awk"
				print ""
				print "#### --if|i"
				print ""
				print "apl condition regex"
				print ""
				print "- Ex confition for stdout"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku apl -i \x22aa\x22 \x22sed \x27s/^/PREFIX/\x27\x22"
				print ""
				print "->"
				print "PREFIXaa\nbb"
				print "```"
				print ""
				print "- Ex confition for proc"
				print ""
				print "```.sh.sh"
				# print "echo \x22aa\nbb\x22 | aku apl -i \x22aa\x22 \x22touch @{0}; echo @{0}\x22"
				print "```"
				print ""
				print "#### --field-num|-f"
				print ""
				print "target field"
				print ""
				print "- Ex single field (default: all)"
				print ""
				print "```sh.sh"
				print "echo \x22aa\x22    bb   cc    #dd\x22 | aku apl \x22echo @[1}\x22 -f \x222\x22"
				print "```"
				print ""
				print "- Ex multiple field"
				print ""
				print "```sh.sh"
				print "echo \x22aa\x22    bb   cc    #dd\x22 | aku apl \x22echo @[1}\x22 -f \x221\x22 -f \x223-4\x22"
				print "```"
				print ""
				print "- Ex multiple field by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa\x22    bb   cc    #dd\x22 | aku apl \x22echo @[1}\x22 \x221\x22 -f \x22-4\x22"
				print "```"
				print ""
				print "- Ex multiple field by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa\x22    bb   cc    #dd\x22 | aku apl \x22echo @[1}\x22 -f \x221\x22 -f \x222-\x22"
				print "```"
				print ""
				print "#### --row-num|-r"
				print ""
				print "target row (default: all)"
				print ""
				print "- Ex single row"
				print ""
				print "```sh.sh"
				print "echo ~\x22 | aku apl \x22echo @[1}\x22 -r \x222\x22"
				print "```"
				print ""
				print "- Ex multiple row"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku apl \x22echo @[1}\x22 -r \x221\x22 -r \x223-4\x22"
				print "```"
				print ""
				print "- Ex multiple row by end range"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku apl \x22echo @[1}\x22 -r \x221\x22 -r \x22-4\x22"
				print "```"
				print ""
				print "- Ex range specify -end"
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku apl \x22echo @[1}\x22 \x22[a-z]\x22 -r -2"
				print "->"
				print "A\nB\nccC\nDdd"
				print "```"
				print ""
				print "- Ex range specify -start "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbwBb\nccC\nDdd\x22 | aku apl \x22echo @[1}\x22 \x22[a-z]x22 -r 2-"
				print "->"
				print "aaA\nB\nC\nD"
				print "```"
				print ""
				print "- Ex range specify start-end "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku apl \x22echo @[1}\x22 \x22[a-z]\x22 -r 2-4"
				print "->"
				print "aaA\nB\nC\nD"
				print "```"
				print ""
				print "- Ex multiple "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku apl \x22echo @[1}\x22 \x22[a-z]\x22 -r 1 -r 3-4"
				print "->"
				print "A\nbBb\ncC\nD"
				print "```"
				print ""
				print "#### --on-negative|-n"
				print ""
				print "negative to field num and row num"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku apl \x22echo @[1}\x22 -n -f \x222\x22 -d \x2AAA\x22"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}

exec_apl(){
	local apl_awk_path="${APL_DIR_PATH}/apl.awk"
	local contain_num_separator=","
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
		-i "${apl_awk_path}"\
		-F "${DELIMITTER}" \
		-v src_con="${CONTENTS}"\
		-v DELIMITTER="${DELIMITTER}"\
		-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
		-v max_nf_num="${max_nf_num}"\
		-v REGEX_CON="${REGEX_CON}"\
		-v CMD_CON="${CMD_CON}"\
	 	-v ON_NEGATIVE="${ON_NEGATIVE}"\
	'BEGIN{
			DISPLAY_FIELD_NUM_CON = make_list_from_muti_list_con(\
				FIELD_NUM_LIST_CON, \
				max_nf_num,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
			gsub(CONTAIN_NUM_SEPARATOR, "", FIELD_NUM_LIST_CON)
			DISPLAY_FIELD_NUM_CON = trim_separator(DISPLAY_FIELD_NUM_CON, CONTAIN_NUM_SEPARATOR)
			DISPLAY_FIELD_NUM_CON = sort_list_con(DISPLAY_FIELD_NUM_CON, CONTAIN_NUM_SEPARATOR)
			DISPLAY_FIELD_NUM_CON = remove_dup_el(DISPLAY_FIELD_NUM_CON, CONTAIN_NUM_SEPARATOR)
			# print "DISPLAY_FIELD_NUM_CON "DISPLAY_FIELD_NUM_CON

			max_lines = split(src_con, _line_array, "\n")
			# print "CONTAIN_NUM_SEPARATOR "CONTAIN_NUM_SEPARATOR
			# print "ROW_NUM_LIST_CON "ROW_NUM_LIST_CON
			# print "NUM_LIST_CON_SEPARATOR "NUM_LIST_CON_SEPARATOR
			DISPLAY_ROW_NUM_CON = make_list_from_muti_list_con(\
				ROW_NUM_LIST_CON, \
				max_lines,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
			DISPLAY_ROW_NUM_CON = trim_separator(DISPLAY_ROW_NUM_CON, CONTAIN_NUM_SEPARATOR)
			DISPLAY_ROW_NUM_CON = sort_list_con(DISPLAY_ROW_NUM_CON, CONTAIN_NUM_SEPARATOR)
			DISPLAY_ROW_NUM_CON = remove_dup_el(DISPLAY_ROW_NUM_CON, CONTAIN_NUM_SEPARATOR)
			# print "11 DISPLAY_ROW_NUM_CON " DISPLAY_ROW_NUM_CON
			gsub(CONTAIN_NUM_SEPARATOR, "", ROW_NUM_LIST_CON)
			# print "ON_NEGATIVE "ON_NEGATIVE
	}{
		# print "$0 "$0
		match_row_num = sprintf("%s%s%s", CONTAIN_NUM_SEPARATOR, NR, CONTAIN_NUM_SEPARATOR)
		is_pass_row_num = 0
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
			is_pass_row_num = 1
		}
		if(\
			!ON_NEGATIVE \
			&& is_pass_row_num\
		){
			print $0
			next
		}else if (\
			ON_NEGATIVE \
			&& ROW_NUM_LIST_CON\
			&& !is_pass_row_num\
		) {
			print $0
			next
		}
		target_str = ""
		if(!FIELD_NUM_LIST_CON){
			target_str = $0
		}

		el_list[0] = $0
		for(l=0; l<=max_nf_num;l++){
			el_list[l] = $l
		}

		if(FIELD_NUM_LIST_CON == ""){
			print exec_apl_by_awk(\
				target_str,\
				REGEX_CON,\
				CMD_CON,\
				el_list,\
				max_nf_num\
			)
			next
		}
		line = ""
		for(l=1;l<=NF;l++){
			is_pass_field_num = 0
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
				is_pass_field_num = 1
			}
			if(\
				!ON_NEGATIVE \
				&& is_pass_field_num\
			){
				line = sprintf("%s%s%s",line, $l, DELIMITTER)
				continue
			}else if (\
				ON_NEGATIVE \
				&& FIELD_NUM_LIST_CON\
				&& !is_pass_field_num\
			) {
				line = sprintf("%s%s%s",line, $l, DELIMITTER)
				continue
			}
			el = exec_apl_by_awk(\
				$l,\
				REGEX_CON,\
				CMD_CON,\
				el_list,\
				max_nf_num\
			)
			if(l == NF){
				line = sprintf("%s%s", line, el)
				continue
			}
			line = sprintf("%s%s%s",line, el, DELIMITTER)
			# print "## line"line"CC"
		}
		print line
	}'
}
