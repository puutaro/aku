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
				print "Arg or stdin"
				print "### Option"
				print "#### --field-num|-f"
				print "target field"
				print "- [Ex1] single field (default: all)"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x222\x22"
				print ""
				print "->"
				print "bb"
				print ""
				print "- [Ex2] multiple field"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x223-4\x22"
				print ""
				print "->"
				print "aa\tcc\t#dd"
				print ""
				print "- [Ex3] multiple field by end range"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x22-4\x22"
				print ""
				print "->"
				print "aa\tbb\tcc\t#dd"
				print ""
				print "- [Ex4] multiple field by end range"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x222-\x22"
				print ""
				print "->"
				print "bb\tcc\t#dd"
				print ""
				print "#### --row-num|-r"
				print "target row (default: all)"
				print "- [Ex1] single row"
				print "echo ~\x22 | aku cut -r \x222\x22 | aku cut"
				print ""
				print "- [Ex2] multiple row"
				print "echo \x22~\x22 | aku cut -r \x221\x22 -r \x223-4\x22"
				print ""
				print "- [Ex3] multiple row by end range"
				print "echo \x22~\x22 | aku cut -r \x221\x22 -r \x22-4\x22"
				print ""
				print "#### --delimitter|-d"
				print "delimitter (default is space)"
				print "- [Ex1] string delimitter"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku cut -f \x222\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "bb"
				print ""
				print "- [Ex2] consec space delimiter"
				print "echo \x22aa  bb     cc      #dd\x22 | aku cut -f \x222\x22 -d \x22 \x22"
				print ""
				print "->"
				print "bb"
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
			# print "DISPLAY_FIELD_NUM_CON "DISPLAY_FIELD_NUM_CON
			max_lines = split(src_con, _line_array, "\n")
			# print "CONTAIN_NUM_SEPARATOR "CONTAIN_NUM_SEPARATOR
			DISPLAY_ROW_NUM_CON = make_list_from_muti_list_con(\
				ROW_NUM_LIST_CON, \
				max_lines,\
				NUM_LIST_CON_SEPARATOR,\
				CONTAIN_NUM_SEPARATOR\
			)
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
