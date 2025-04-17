#!/bin/bash


read_args_for_cut(){
	local is_already_first_con=0
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
		--row-num|-r)
			ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"	
			shift
			;;
		--delimitter|-d)
			DELIMITTER="${2}"
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
			if [ ${is_already_first_con} -gt 0 ];then
				CONTENTS+="${1:-}"
			fi
			is_already_first_con=1
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
}

display_help_for_cut(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Cut"
				print "Cut field by awk spec"
				print ""
				print "### ARG"
				print ""
				print "Arg or stdin"
				print ""
				print "### Option"
				print ""
				print "#### --field-num|-f"
				print ""
				print "target field"
				print ""
				print "- Ex single field (default: all)"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x222\x22"
				print ""
				print "->"
				print "bb"
				print "```"
				print ""
				print "- Ex multiple field"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x223-4\x22"
				print ""
				print "->"
				print "aa\tcc\t#dd"
				print "```"
				print ""
				print "- Ex multiple field by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x22-4\x22"
				print ""
				print "->"
				print "aa\tbb\tcc\t#dd"
				print "```"
				print ""
				print "- Ex multiple field by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x222-\x22"
				print ""
				print "->"
				print "bb\tcc\t#dd"
				print "```"
				print ""
				print "#### --row-num|-r"
				print ""
				print "target row (default: all)"
				print ""
				print "- Ex single row"
				print ""
				print "```sh.sh"
				print "echo ~\x22 | aku cut -r \x222\x22 | aku cut"
				print "```"
				print ""
				print "- Ex multiple row"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku cut -r \x221\x22 -r \x223-4\x22"
				print "```"
				print ""
				print "- Ex multiple row by end range"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku cut -r \x221\x22 -r \x22-4\x22"
				print "```"
				print ""
				print "#### --delimitter|-d"
				print ""
				print "delimitter (default is space)"
				print ""
				print "- Ex string delimitter"
				print ""
				print "```sh.sh"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku cut -f \x222\x22 -d \x2AAA\x22"
				print "```"
				print ""
				print "->"
				print "bb"
				print "```"
				print ""
				print "- Ex consec space delimiter"
				print ""
				print "```sh.sh"
				print "echo \x22aa  bb     cc      #dd\x22 | aku cut -f \x222\x22 -d \x22 \x22"
				print ""
				print "->"
				print "bb"
				print "```"
				print ""
				print "#### --on-negative|-n"
				print ""
				print "negative cut"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku cut -n -f \x222\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "aaAAAccAAA#dd"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_cut(){
	local contain_num_separator=","
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
		-F "${DELIMITTER}" \
		-v src_con="${CONTENTS}" \
		-v ON_NEGATIVE="${ON_NEGATIVE}"\
	 	-v FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
	 	-v DELIMITTER="${DELIMITTER}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v max_nf_num="${max_nf_num}"\
		'BEGIN{
			# print "FIELD_NUM_LIST_CON: "FIELD_NUM_LIST_CON
			DISPLAY_FIELD_NUM_CON = make_list_from_muti_list_con(\
				FIELD_NUM_LIST_CON, \
				max_nf_num,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
			gsub(CONTAIN_NUM_SEPARATOR, "", FIELD_NUM_LIST_CON)
			print "FIELD_NUM_LIST_CON "FIELD_NUM_LIST_CON
			# print "DISPLAY_FIELD_NUM_CON "DISPLAY_FIELD_NUM_CON
			max_lines = split(src_con, _line_array, "\n")
			# print "CONTAIN_NUM_SEPARATOR "CONTAIN_NUM_SEPARATOR
			DISPLAY_ROW_NUM_CON = make_list_from_muti_list_con(\
				ROW_NUM_LIST_CON, \
				max_lines,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
			gsub(CONTAIN_NUM_SEPARATOR, "", ROW_NUM_LIST_CON)
			print "ROW_NUM_LIST_CON "ROW_NUM_LIST_CON
			# print "DISPLAY_ROW_NUM_CON "DISPLAY_ROW_NUM_CON

			last_output = ""
		}
	{
		is_pass_row_num = 0
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
			is_pass_row_num = 1
		}
		if(\
			!ON_NEGATIVE \
			&& is_pass_row_num\
		){
			next
		}else if (\
			ON_NEGATIVE \
			&& ROW_NUM_LIST_CON\
			&& !is_pass_row_num\
		) {
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
				continue
			}else if (\
				ON_NEGATIVE \
				&& FIELD_NUM_LIST_CON\
				&& !is_pass_field_num\
			) {
				continue
			}
			if(l == NF){
				line = sprintf("%s%s", line, $l)
				continue
			}
			line = sprintf("%s%s%s",line, $l, DELIMITTER)
		}
		print line
	}'
}
