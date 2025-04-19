#!/bin/bash


read_args_for_iro(){
	local count_arg_input=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--turn|-t)
			TURN="${2}"
			shift
			;;
		--field-num|-f)
			FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		---delimitter|-d)
			DELIMITTER="${2}"
			shift
			;;
		-row-num|-r)
			ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON}${NUM_LIST_CON_SEPARATOR}${2}"	
			shift
			;;
		--on-negative|-n)
			ON_NEGATIVE="on"
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
				PROPERTY="${1:-}"
			elif [ ${count_arg_input} -eq 2 ]; then
				REGEX_CON="${1:-}"
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

display_help_for_iro(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Iro"
				print ""
				print "Coloring by hex string"
				print ""
				print "### ARG"
				print ""
				print "Arg"
				print ""
				print "#### first arg"
				print ""
				print "property (default color:green,bold)"
				print ""
				print "##### key"
				print ""
				print "- color: text color"
				print ""
				print "pre reserved color string: black, whited"
				print "bellow exist d- / l- type"
				print "green, azure, blue, red, brown, yellow"
				print ""
				print "- back: background color"
				print ""
				print "- under: under line"
				print ""
				print "- bold: bold text"
				print ""
				print "- Ex default color: green"
				print ""
				print "echo \x22aa\nbb\x22 | aku iro"
				print ""
				print "- Ex blue text & light red background & bold & under line"
				print ""
				print "```sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro color:blue,back:lred,bold,under"
				print "```"
				print ""
				print "- Ex hex color stirng"
				print ""
				print "```sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro \x22color:#2f41ba\x22"
				print "```"
				print ""
				print "- Ex enable hex num specify"
				print ""
				print "```sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro color:2f41ba"
				print "```"
				print ""
				print "- Ex blue text & light red background & bold & under line"
				print ""
				print "```sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro color:blue,back:lred,bold,under"
				print "```"
				print ""
				print "- Ex short syntax"
				print ""
				print "```sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro dgreen"
				print "```"
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
				print "echo \x22aa    bb   cc    #dd\x22 | aku iro \x22color:green\x22 -f \x222\x22"
				print "```"
				print ""
				print "- Ex multiple field"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku iro -f \x221\x22 -f \x223-4\x22"
				print "```"
				print ""
				print "- Ex multiple field by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku iro -f \x221\x22 -f \x22-4\x22"
				print "```"
				print ""
				print "- Ex multiple field by end range"
				print ""
				print "```sh.sh"
				print "echo \x22aa    bb   cc    #dd\x22 | aku iro -f \x221\x22 -f \x222-\x22"
				print "```"
				print ""
				print "#### --row-num|-r"
				print ""
				print "target row (default: all)"
				print ""
				print "- Ex single row"
				print ""
				print "```sh.sh"
				print "echo ~\x22 | aku iro -r \x222\x22 | aku"
				print "```"
				print ""
				print "- Ex multiple row"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku iro -r \x221\x22 -r \x223-4\x22"
				print "```"
				print ""
				print "- Ex multiple row by end range"
				print ""
				print "```sh.sh"
				print "echo \x22~\x22 | aku iro -r \x221\x22 -r \x22-4\x22"
				print "```"
				print ""
				print "#### --delimitter|-d"
				print ""
				print "delimitter (default is space)"
				print ""
				print "- Ex string delimitter"
				print ""
				print "```sh.sh"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku iro red -f \x222\x22 -d \x2AAA\x22"
				print "```"
				print "```"
				print ""
				print "- Ex consec space delimiter"
				print ""
				print "```sh.sh"
				print "echo \x22aa  bb     cc      #dd\x22 | aku iro \x22color:#847334\x22 -f \x222\x22 -d \x22 \x22"
				print "```"
				print ""
				print "#### --on-negative|-n"
				print ""
				print "negative to field num and row num"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku iro -n -f \x222\x22 -d \x2AAA\x22"
				print "```"
				print ""
				print "#### second arg (default : blank)"
				print ""
				print "target str saround by ()"
				print ""
				print "- Ex "
				print ""
				print "```sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro \x27(aa)bb\x27"
				print ""
				print "->"
				print "\nbb"
				print "```"
				print ""
				print "#### --input-i"
				print ""
				print "recieve input"
				print "```"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku iro \x22aa\x22 -i \x22aa\nbb\x22"
				print "->"
				print "\nbb"
				print "```"
				print ""
				print "#### --turn|-t"
				print ""
				print "- Ex"
				print ""
				print "```.sh.sh"
				print "echo \x22aa\nbb\x22 | aku iro \x22(a)\nb\x22 \x22\\\\1SUFFIX\x22 -t 1"
				print "->"
				print "aaSUFFIX\nbb"
				print "```"
				print ""
				print "- Ex range specify -end"
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku iro \x22[a-z]\x22 -r -2"
				print "->"
				print "A\nB\nccC\nDdd"
				print "```"
				print ""
				print "- Ex range specify -start "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbwBb\nccC\nDdd\x22 | aku iro \x22[a-z]x22 -r 2-"
				print "->"
				print "aaA\nB\nC\nD"
				print "```"
				print ""
				print "- Ex range specify start-end "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku iro \x22[a-z]\x22 -r 2-4"
				print "->"
				print "aaA\nB\nC\nD"
				print "```"
				print ""
				print "- Ex multiple "
				print ""
				print "```.sh.sh"
				print "echo \x22aaA\nbBb\nccC\nDdd\x22 | aku iro \x22[a-z]\x22 -r 1 -r 3-4"
				print "->"
				print "A\nbBb\ncC\nD"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_iro(){
	local iro_awk_funcs="${IRO_DIR_PATH}/iro.awk"
	local contain_num_separator=","
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
		-i "${iro_awk_funcs}"\
		-F "${DELIMITTER}" \
		-v DELIMITTER="${DELIMITTER}"\
		-v src_con="${CONTENTS}" \
	 	-v TURN="${TURN}" \
	 	-v ROW_NUM_LIST_CON="${ROW_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON#${NUM_LIST_CON_SEPARATOR}}" \
	 	-v NUM_LIST_CON_SEPARATOR="${NUM_LIST_CON_SEPARATOR}" \
	 	-v REGEX_CON="${REGEX_CON}"\
	 	-v PROPERTY="${PROPERTY#${PROPERTY_SEPARATOR}}"\
	 	-v PROPERTY_SEPARATOR="${PROPERTY_SEPARATOR}"\
	 	-v CONTAIN_NUM_SEPARATOR="${contain_num_separator}"\
	 	-v ON_NEGATIVE="${ON_NEGATIVE}"\
	 	-v max_nf_num="${max_nf_num}"\
		'BEGIN{
			pre_green_key = "green"
			PRE_COLOR_MAP["lgreen"] = "#43fa46"
			PRE_COLOR_MAP[pre_green_key] = "#11b812"
			PRE_COLOR_MAP["dgreen"] = "#014702"
			PRE_COLOR_MAP["lred"] = "#fa4d4d"
			PRE_COLOR_MAP["red"] = "#ff0000"
			PRE_COLOR_MAP["dred"] = "#850101"
			PRE_COLOR_MAP["lblue"] = "#26c0fc"
			PRE_COLOR_MAP["blue"] = "#0026ff"
			PRE_COLOR_MAP["dblue"] = "#001d9e"
			PRE_COLOR_MAP["lazure"] = "#67e8eb"
			PRE_COLOR_MAP["azure"] = "#21ebc6"
			PRE_COLOR_MAP["dazure"] = "#1c4d44"
			PRE_COLOR_MAP["yellow"] = "#fff200"
			PRE_COLOR_MAP["lbrown"] = "#f26e27"
			PRE_COLOR_MAP["brown"] = "#b35c15"
			PRE_COLOR_MAP["dbrown"] = "#572b07"
			PRE_COLOR_MAP["black"] = "#000000"
			PRE_COLOR_MAP["white"] = "#ffffff"
			COLOR_KEY = "color"
			BACK_KEY = "back"
			UNDER_LINE_KEY = "under"
			BOLD_KEY = "bold"
			PROPERTY_MAP[COLOR_KEY] = PRE_COLOR_MAP[pre_green_key]
			PROPERTY_MAP[BOLD_KEY] = ""
			PROPERTY_MAP[BACK_KEY] = ""
			PROPERTY_MAP[UNDER_LINE_KEY] = ""
			short_text_color = PRE_COLOR_MAP[PROPERTY]
			if(short_text_color){
				PROPERTY_MAP[COLOR_KEY] = short_text_color
			}
			# print "PROPERTY" PROPERTY
			# print "short_text_color "short_text_color
			property_list_len = split(PROPERTY, property_list, PROPERTY_SEPARATOR)
			for(l = 1; l <= property_list_len; l++){
				key_to_con = property_list[l]
				if(!key_to_con) continue	
				key_to_con_list_len = split(key_to_con, key_to_con_list, ":")
				key = key_to_con_list[1]
				con = key_to_con_list[2]
				gsub(/[ \t]/, "", key)
				gsub(/[ \t]/, "", con)
				if(\
					key == UNDER_LINE_KEY\
					|| key == BOLD_KEY\
				){
					PROPERTY_MAP[key] = "on"
					continue
				}
				is_color_key = \
					key == COLOR_KEY\
					|| key == BACK_KEY
				if(!is_color_key){
					continue
				}
				pre_color = PRE_COLOR_MAP[con]
				if(pre_color){
					PROPERTY_MAP[key] = pre_color 
					continue
				} 
				hex_color_str_entry = gensub(/^([^#])/, "#\\1", "1", con)
				if(\
					is_hex_color(hex_color_str_entry)\
				){
					PROPERTY_MAP[key] = hex_color_str_entry 
					continue
				}
			}
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
			# print "11 DISPLAY_FIELD_NUM_CON " DISPLAY_FIELD_NUM_CON
			max_lines = split(src_con, _line_array, "\n")
			# print "CONTAIN_NUM_SEPARATOR "CONTAIN_NUM_SEPARATOR
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
			# print "ROW_NUM_LIST_CON "ROW_NUM_LIST_CON
			# print "DISPLAY_ROW_NUM_CON "DISPLAY_ROW_NUM_CON
		}
	{
		# print "## "$0
		# print "DISPLAY_ROW_NUM_CON "DISPLAY_ROW_NUM_CON
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
		if(!FIELD_NUM_LIST_CON){
			print make_text_by_color(\
				$0,\
				REGEX_CON,\
				TURN,\
				PROPERTY_MAP,\
				COLOR_KEY,\
				BACK_KEY,\
				BOLD_KEY,\
				UNDER_LINE_KEY\
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
			el = make_text_by_color(\
					$l,\
					REGEX_CON,\
					TURN,\
					PROPERTY_MAP,\
					COLOR_KEY,\
					BACK_KEY,\
					BOLD_KEY,\
					UNDER_LINE_KEY\
				)
			if(l == NF){
				line = sprintf("%s%s", line, el)
				continue
			}
			line = sprintf("%s%s%s",line, el, DELIMITTER)
		}
		print line
	}'
}
