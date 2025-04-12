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
	case "${DELIMITTER}" in
		"") DELIMITTER=" "
			;;
	esac
}

display_help_for_cut(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## cut field by awk spec"
				print ""
				print "### [ARG]"
				print "\tArg or stdin"
				print "### [Option]"
				print "\t--field-num|-f"
				print "\t\ttarget field"
				print "#### [Ex1] single field (default: all)"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x222\x22"
				print ""
				print "->"
				print "bb"
				print ""
				print "#### [Ex2] multiple field"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x223-4\x22"
				print ""
				print "->"
				print "aa\tcc\t#dd"
				print ""
				print "#### [Ex3] multiple field by end range"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x22-4\x22"
				print ""
				print "->"
				print "aa\tbb\tcc\t#dd"
				print ""
				print "#### [Ex4] multiple field by end range"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x222-\x22"
				print ""
				print "->"
				print "bb\tcc\t#dd"
				print ""
				print "\t--row-num|-r"
				print "\t\ttarget row (default: all)"
				print "#### [Ex1] single row"
				print "echo ~\x22 | aku cut -r \x222\x22 | aku cut"
				print ""
				print "#### [Ex2] multiple row"
				print "echo \x22~\x22 | aku cut -r \x221\x22 -r \x223-4\x22"
				print ""
				print "#### [Ex3] multiple row by end range"
				print "echo \x22~\x22 | aku cut -r \x221\x22 -r \x22-4\x22"
				print ""
				print "\t--delimitter|-d"
				print "\t\tdelimitter (default is space)"
				print "#### [Ex1] string delimitter"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku cut -f \x222\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "bb"
				print ""
				print "#### [Ex2] consec space delimiter"
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
		-F "${DELIMITTER}" \
		-v src_con="${CONTENTS}" \
	 	-v FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
	 	-v DELIMITTER="${DELIMITTER}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v max_nf_num="${max_nf_num}"\
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
		  	printf( "contain no number in --field-num|-f arg: %s\n", nums_con)
		  	exit
		}
		BEGIN{
			field_num_list_len = split(FIELD_NUM_LIST_CON, field_num_list, NUM_LIST_CON_SEPARATOR)
			DISPLAY_FIELD_NUM_CON = ""
			for(l=1; l <= field_num_list_len; l++){
				field_num_con = field_num_list[l]
				DISPLAY_FIELD_NUM_CON = sprintf(\
					"%s%s%s",
					DISPLAY_FIELD_NUM_CON,\
					CONTAIN_NUM_SEPARATOR,
					convert_nums_by_compa(field_num_con, max_nf_num))
			}
			gsub(/,+/, ",", DISPLAY_FIELD_NUM_CON)

			max_lines = split(src_con, _line_array, "\n")
			row_num_list_len = split(ROW_NUM_LIST_CON, row_num_list, NUM_LIST_CON_SEPARATOR)
			DISPLAY_ROW_NUM_CON = ""
			for(l=1; l <= row_num_list_len; l++){
				row_num_con = row_num_list[l]
				DISPLAY_ROW_NUM_CON = sprintf(\
					"%s%s%s",
					DISPLAY_ROW_NUM_CON,\
					CONTAIN_NUM_SEPARATOR,
					convert_nums_by_compa(row_num_con, max_lines))
			}
			gsub(/,+/, ",", DISPLAY_ROW_NUM_CON)

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
