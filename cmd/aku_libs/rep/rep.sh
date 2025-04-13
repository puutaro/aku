#!/bin/bash


read_args_for_rep(){
	local is_already_first_con=0
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
		--turn|-t)
			TURN="${2}"
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
	case "${OUTPUT_DELIMITER}" in
		"") OUTPUT_DELIMITER="${DELIMITTER}"
			;;
	esac
	case "${TURN}" in
		"") TURN="g"
			;;
	esac
}

display_help_for_rep(){
	case "${HELP}" in
		"")
			;;
		*)
			awk 'BEGIN {
				print "## Rep"
				print "Replace field"
				print ""
				print "### ARG"
				print "Arg or stdin"
				print "### Option"
				print "#### --field-num-to-delete-regex|-f"
				print "target field to remove regex"
				print "- [Ex1] single field"
				print "echo \x22aa1 bb cc #dd\x22 | aku rep -f \x221:^aa\x22"
				print ""
				print "->"
				print "1 bb cc #dd"
				print ""
				print "- [Ex3] by end range"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x22-4:^[a-z]\x22"
				print ""
				print "->"
				print "a b c #dd"
				print ""
				print "- [Ex4] by end range"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x222-:^[a-z]\x22"
				print ""
				print "->"
				print "aa b c #dd"
				print ""
				print "#### --field-num-to-str|-s"
				print "replace target field to str with remove regex"
				print "- [Ex1] single field"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x221:^[a-z]\x22 -s \x221:CC\x22"
				print ""
				print "->"
				print "CCa bb cc #dd"
				print ""
				print "- [Ex2] by range"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x222-:^[a-z]\x22 -s \x223-4:CC\x22"
				print ""
				print "->"
				print "aa b CCc #dd"
				print ""
				print "- [Ex3] by end range"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x222:^[a-z]\x22 -s \x22-4:CC\x22"
				print ""
				print "->"
				print "aa UUb cc #dd"
				print ""
				print "- [Ex4] by end range"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x223:[a-z]$\x22 -s \x222-:TTx22"
				print ""
				print "->"
				print "aa bb cTT #dd"
				print ""
				print "#### --delimitter|-d"
				print "delimitter (default is space)"
				print "- [Ex1] string delimitter"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku rep -f \x222:bb\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "aaAAAbbAAAccAAA#dd"
				print ""
				print "#### --output-delimiter|-o"
				print "output delimiter (deafult is delimiter)"
				print "- [Ex]"
				print "echo \x22aa  bb     cc      #dd\x22 | aku rep -o \x22\t\x22"
				print ""
				print "->"
				print "bb cc"
				print ""
				print "#### --turn|-t"
				print "gnu awk gensub third parameter"
				print "- [Ex]"
				print "echo \x22aa bb cc #dd\x22 | aku rep -f \x221:B\x22 -t \x221\x22"
				print ""
				print "->"
				print "Ba bb cc #dd"
				print ""
			}' | less
			exit 0
			;;
	esac
}

exec_rep(){
	local contain_num_separator=","
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-F "${DELIMITTER}" \
	 	-v FIELD_NUM_TO_REMOVE_REGEX_CON="${FIELD_NUM_TO_REMOVE_REGEX_CON}" \
	 	-v FIELD_NUM_TO_STR_CON="${FIELD_NUM_TO_STR_CON}" \
	 	-v OUTPUT_DELIMITER="${OUTPUT_DELIMITER}"\
	 	-v TURN="${TURN}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v NUM_REGEX_SEPARATOR="${NUM_REGEX_SEPARATOR}"\
	 	-v max_nf_num="${max_nf_num}" \
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
			nums_by_coma = convert_nums_by_compa(field_num_con, max_nf_num)
			DISPLAY_FIELD_NUM_CON = sprintf(\
				"%s%s",
				CONTAIN_NUM_SEPARATOR,
				nums_by_coma)
			nums_list_len = split(nums_by_coma, nums_list, contain_num_separator)
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
			nums_by_coma = convert_nums_by_compa(field_num_con, max_nf_num)
			STR_FIELD_NUM_CON = sprintf(\
				"%s%s",
				CONTAIN_NUM_SEPARATOR,
				nums_by_coma)
			nums_list_len = split(nums_by_coma, nums_list, contain_num_separator)
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
			max_lines = split(src_con, _line_array, "\n")
			last_output = ""
		}
	{
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
				if(!line){
					line = $l
					continue
				}
				line = sprintf("%s%s%s", line, OUTPUT_DELIMITER, $l)
				continue
			}
			cur_regex = FIELD_NUM_TO_REMOVE_REGEX_MAP[l]
			cur_str = FIELD_NUM_TO_STR_MAP[l]
			$l = gensub(cur_regex, cur_str, TURN, $l)
			if(!line){
				line = $l
			}else{ 
				line = sprintf("%s%s%s", line, OUTPUT_DELIMITER, $l)
			}
		}
		if(!last_output){
			last_output = line
			next
		}
		last_output = sprintf("%s\n%s", last_output, line)
	}
	END {
		regex_last_delmiter = sprintf("%s$", OUTPUT_DELIMITER)
		gsub(regex_last_delmiter, "", last_output)
		print last_output
	}'
}
