#!/bin/bash


read_args_for_mch(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--field-num-to-regex|-f)
			FIELD_NUM_TO_REGEX_LIST_CON="${FIELD_NUM_TO_REGEX_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--negative-field-num-to-regex|-n)
			FIELD_NUM_TO_NEGATIVE_REGEX_LIST_CON="${FIELD_NUM_TO_NEGATIVE_REGEX_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--delimitter|-d)
			DELIMITTER="${2}"
			shift
			;;
		--and|-a)
			ON_AND="on"
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
	if [ -z "${FIELD_NUM_TO_REGEX_LIST_CON}" ] \
		&& [ -z "${FIELD_NUM_TO_NEGATIVE_REGEX_LIST_CON}" ]\
		&& [ -z ${HELP} ] ;then
			echo "field num to regex and negtive one not found" 
			exit 1
	fi
	case "${DELIMITTER}" in
		"") DELIMITTER=" "
			;;
	esac
}

display_help_for_mch(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## This is Matcher"
				print "As feature, enable matching to field by regex"
				print ""
				print "### [ARG]"
				print "\tArg or stdin"
				print "### [Option]"
				print "\t--field-num-to-regex|-f"
				print "\t\ttarget field to regex"
				print "#### [Ex1] single field"
				print "echo \x22aa bb cc #dd\x22 | aku mch -f \x221:^aa$\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "#### [Ex2] multiple field"
				print "echo \x22aa bb cc #dd\x22 | aku mch -f \x221:^aa$\x22 -f \x223-4:.*\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "#### [Ex3] multiple field by end range"
				print "echo \x22aa bb cc #dd\x22 | aku mch -f \x221:^aa$\x22 -f \x22-4:.*\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "#### [Ex4] multiple field by end range"
				print "echo \x22aa bb cc #dd\x22 | aku mch -f \x221:^aa$\x22 -f \x222-:.*\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "\t--negative-field-num-to-regex|-n"
				print "\t\tnegative target field to regex"
				print "#### [Ex1] single negative field"
				print "echo \x22aa bb cc #dd\x22 | aku mch -n \x221:^cc$\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "#### [Ex2] multiple negative field"
				print "echo \x22aa bb cc #dd\x22 | aku mch -n \x221:^cc$\x22 -n \x223-4:tt\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "#### [Ex3] multiple negative field by end range"
				print "echo \x22aa bb cc #dd\x22 | aku mch -n \x221:^rr$\x22 -n \x22-4:tt\x22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "#### [Ex4] multiple negative field by end range"
				print "echo \x22aa bb cc #dd\x22 | aku mch -f \x221:^rr$\x22 -f \x222-:ttx22"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print "\t--delimitter|-d"
				print "\t\tdelimitter (default is space)"
				print "#### [Ex1] string delimitter"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku cut -f \x222:bb\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "aaAAAbbAAAccAAA#dd"
				print ""
				print "\t--and|-a"
				print "\t\tenable and match"
				print "#### [Ex]"
				print "echo \x22aa bb cc #dd\x22 | aku mch -n \x221:^bb$\x22 -f \x221:^aa$\x22 -a"
				print ""
				print "->"
				print "aa bb cc #dd"
				print ""
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_mch(){
	local contain_num_separator=","
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-F "${DELIMITTER}" \
	 	-v FIELD_NUM_TO_REGEX_LIST_CON="${FIELD_NUM_TO_REGEX_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v FIELD_NUM_TO_NEGATIVE_REGEX_LIST_CON="${FIELD_NUM_TO_NEGATIVE_REGEX_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
	 	-v DELIMITTER="${DELIMITTER}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v NUM_REGEX_SEPARATOR="${NUM_REGEX_SEPARATOR}"\
	 	-v max_nf_num="${max_nf_num}" \
	 	-v ON_AND="${ON_AND}"\
		' function convert_nums_by_compa(nums_con, max_num){
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
			field_num_to_regex_list_len = split(FIELD_NUM_TO_REGEX_LIST_CON, field_num_to_regex_list, NUM_LIST_CON_SEPARATOR)
			# print "FIELD_NUM_TO_REGEX_LIST_CON "FIELD_NUM_TO_REGEX_LIST_CON
			# print "field_num_to_regex_list_len "field_num_to_regex_list_len
			DISPLAY_FIELD_NUM_CON = ""
			FIELD_NUM_TO_REGEX_MAP[0] = ""
			ALL_MATCH_COUNT = 0
			for(l=1; l <= field_num_to_regex_list_len; l++){
				field_num_to_regex_con = field_num_to_regex_list[l]
				field_num_con ="" 
				regex_list_con ="" 
				colonPos = index(field_num_to_regex_con, NUM_REGEX_SEPARATOR) # 最初のコロンの位置を取得
				if(colonPos == 0) {
					print "field num or regex not found: "field_num_to_regex_con > "/dev/stderr"
					exit 1
				}
				field_num_con = substr(field_num_to_regex_con, 1, colonPos - 1)
				regex_list_con = substr(field_num_to_regex_con, colonPos + 1) # コロンの次の文字から最後までを抽出
				# print "field_num_con "field_num_con
				# print "regex_list_con " regex_list_con
				nums_by_coma = convert_nums_by_compa(field_num_con, max_nf_num)
				DISPLAY_FIELD_NUM_CON = sprintf(\
					"%s%s%s",
					DISPLAY_FIELD_NUM_CON,\
					CONTAIN_NUM_SEPARATOR,
					nums_by_coma)
				nums_list_len = split(nums_by_coma, nums_list, contain_num_separator)
				for(j=1;j<=nums_list_len;j++){
					cur_num = nums_list[j]
					if(cur_num !~ /^[0-9]+$/)	 continue
					ALL_MATCH_COUNT++
					cur_filed_num_to_regex = FIELD_NUM_TO_REGEX_MAP[cur_num]
					# print "# j "j
					# print "# cur_num "cur_num
					# print "# cur_filed_num_to_regex "cur_filed_num_to_regex
					if(!cur_filed_num_to_regex){
						FIELD_NUM_TO_REGEX_MAP[cur_num] = regex_list_con
						continue
					}
					FIELD_NUM_TO_REGEX_MAP[cur_num] = sprintf(\
						"%s%s%s",\
						cur_filed_num_to_regex,\
						NUM_LIST_CON_SEPARATOR,\
						regex_list_con\
					)
				}
			}

			field_num_to_negative_regex_list_len = split(FIELD_NUM_TO_NEGATIVE_REGEX_LIST_CON, field_num_to_negative_regex_list, NUM_LIST_CON_SEPARATOR)
			DISPLAY_NEGATIVE_FIELD_NUM_CON = ""
			FIELD_NUM_TO_NEGATIVE_REGEX_MAP[0] = ""
			for(l=1; l <= field_num_to_negative_regex_list_len; l++){
				field_num_to_regex_con = field_num_to_negative_regex_list[l]
				field_num_con ="" 
				regex_list_con ="" 
				colonPos = index(field_num_to_regex_con, NUM_REGEX_SEPARATOR) # 最初のコロンの位置を取得
				if(colonPos == 0) {
					print "negative field num or regex not found: "field_num_to_regex_con > "/dev/stderr"
					exit 1
				}
				field_num_con = substr(field_num_to_regex_con, 1, colonPos - 1)
				regex_list_con = substr(field_num_to_regex_con, colonPos + 1) # コロンの次の文字から最後までを抽出
				# print "negavit field_num_con "field_num_con
				# print "negaitgve regex_list_con " regex_list_con
				nums_by_coma = convert_nums_by_compa(field_num_con, max_nf_num)
				DISPLAY_NEGATIVE_FIELD_NUM_CON = sprintf(\
					"%s%s%s",
					DISPLAY_NEGATIVE_FIELD_NUM_CON,\
					CONTAIN_NUM_SEPARATOR,
					nums_by_coma)
				nums_list_len = split(nums_by_coma, nums_list, contain_num_separator)
				for(j=1;j<=nums_list_len;j++){
					cur_num = nums_list[j]
					if(cur_num !~ /^[0-9]+$/)	 continue
					ALL_MATCH_COUNT++
					cur_filed_num_to_regex = FIELD_NUM_TO_NEGATIVE_REGEX_MAP[cur_num]
					# print "# negative field_num_con "field_num_con
					# print "# negative cur_filed_num_to_regex "cur_filed_num_to_regex
					if(!cur_filed_num_to_regex){
						FIELD_NUM_TO_NEGATIVE_REGEX_MAP[cur_num] = regex_list_con
						continue
					}
					FIELD_NUM_TO_NEGATIVE_REGEX_MAP[cur_num] = sprintf(\
						"%s%s%s",\
						cur_filed_num_to_regex,\
						NUM_LIST_CON_SEPARATOR,\
						regex_list_con\
					)
				}
			}
			max_lines = split(src_con, _line_array, "\n")

			last_output = ""
		}
	{
		if(NF==0) {
			print $0
			next
		}
		# print "## 00" $0

		cur_all_match_count = 0
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
			# print "## NR"NR
			regex_list_con = FIELD_NUM_TO_REGEX_MAP[l]
			regex_list_len = split(regex_list_con, regex_list, NUM_LIST_CON_SEPARATOR)
			# print "## regex_list_con "regex_list_con
			for(k=1; k<=regex_list_len;k++){
				cur_regex = regex_list[k]
				# print "## l: "l
				# print "## cur_regex "cur_regex
				# print "## cur str "$l
				if($l !~ cur_regex){
					# print "## no match"
					 continue
				}
				cur_all_match_count++
			}
		}
		for(l=1;l<=NF;l++){
			match_field_num = sprintf("%s%s%s", CONTAIN_NUM_SEPARATOR, l, CONTAIN_NUM_SEPARATOR)
			if(\
				index(\
					sprintf(\
						"%s%s%s", \
						CONTAIN_NUM_SEPARATOR,\
						DISPLAY_NEGATIVE_FIELD_NUM_CON,\
						CONTAIN_NUM_SEPARATOR\
					), 
					match_field_num)  == 0\
				&& DISPLAY_NEGATIVE_FIELD_NUM_CON\
			) {
				continue
			}
			# print "## NR"NR
			regex_list_con = FIELD_NUM_TO_NEGATIVE_REGEX_MAP[l]
			regex_list_len = split(regex_list_con, regex_list, NUM_LIST_CON_SEPARATOR)
			# print "## regex_list_con "regex_list_con
			for(k=1; k<=regex_list_len;k++){
				cur_regex = regex_list[k]
				# print "## l: "l
				# print "## cur_regex "cur_regex
				# print "## cur str "$l
				if($l ~ cur_regex){
					 continue
				}
				cur_all_match_count++
			}
		}
		# print "## cur_all_match_count "cur_all_match_count
		# print "##  ALL_MATCH_COUNT "ALL_MATCH_COUNT
		if(cur_all_match_count == 0) next
		if(ON_AND && cur_all_match_count < ALL_MATCH_COUNT){
			next	
		}
		print $0
	}'
}