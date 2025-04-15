#!/bin/bash


read_args_for_fld(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--header-row-num|-l)
			HEADER_ROW_NUM="${2}"
			shift
			;;
		--insert-header-cycle|-i)
			INSERT_HEADER_CYCLE=${2}
			shift
			;;
		--fold-col-cycle|-c)
			FOID_COL_CYCLE="${2}"
			shift
			;;
		--prefix|-p)
			PREFIX_STR="${2}"	
			shift
			;;
		--suffix|-s)
			SUFFIX_STR="${2}"	
			shift
			;;
		--no-display-row-num|-n)
			NO_DISPLAY_ROW_NUM="on"
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
				CONTENTS="${1:-}"
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

display_help_for_fld(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Fld"
				print ""
				print "Fold each field"
				print ""
				print "### ARG"
				print ""
				print "Arg or stdin"
				print ""
				print "### Option"
				print ""
				print "#### --insert-header-cycle|-i"
				print ""
				print "insert header cycle (default: 5)"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo ~ | aku fld -i 3"
				print "```"
				print ""
				print "#### --fold-col-cycle|-c"
				print ""
				print "fold col cycle (default: 5)"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku fld -i 3 -c 3 | {file path}"
				print "```"
				print ""
				print "#### --header-row-num|-l"
				print ""
				print "specify header low num (default: 5)"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo ~ | aku fld -i 3 -c 3"
				print "```"
				print ""
				print "#### --insert-header-cycle|-i"
				print ""
				print "insert header cycle (default: 5)"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo ~ | aku fld -i 3"
				print "```"
				print ""
				print "#### --delimiter|-d"
				print ""
				print "field delimiter"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "echo ~ | aku fld -i 3 -d \x27\\t\x27"
				print "```"
				print ""
				print "#### --prefix|-p"
				print ""
				print "header prefix string"
				print ""
				print "- enable with header"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku fld -p \x22###\x22 {file path}"
				print "```"
				print ""
				print "#### --suffix|-s"
				print ""
				print "header suffix string"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku fld -s \x22###\x22 {file path}"
				print "```"
				print ""
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_fld(){
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	readonly header=$(\
		echo "${CONTENTS}" \
		| ${AWK_PATH} \
		-F "${DELIMITTER}" \
		-v HEADER_ROW_NUM="${HEADER_ROW_NUM}"\
		 '{
				if(!HEADER_ROW_NUM) {
					print ""
					exit
				}
				if(NR != HEADER_ROW_NUM) next
				print $0
				exit
		}')
	# echo "HEADER_LINE: ${header}"
	# echo "HEADER_ROW_NUM: ${HEADER_ROW_NUM}"
	# echo "INSERT_HEADER_CYCLE: ${INSERT_HEADER_CYCLE}"
	# echo "FOID_COL_CYCLE: ${FOID_COL_CYCLE}"
	# echo "${CONTENTS}" | ${AWK_PATH} -F "${DELIMITTER}" '{print $0}'
	echo "${CONTENTS}"\
		|${AWK_PATH}\
			-F "${DELIMITTER}" \
			-v DELIMITTER="${DELIMITTER}"\
			-v HEADER_ROW_NUM="${HEADER_ROW_NUM}"\
		 '{
			if(NR == HEADER_ROW_NUM) next
			new_line = ""
			for(l=1; l<=NF; l++){
				el = $l
				if(!new_line){
					new_line = el
					continue
				}
				new_line = sprintf("%s%s%s", new_line, DELIMITTER, el)
			}
			print new_line
		}'\
	| ${AWK_PATH} \
		-F "${DELIMITTER}" \
		-v CONTENTS="${CONTENTS}"\
		-v MAX_NF_NUM="${max_nf_num}"\
		-v HEADER_LINE="${header}"\
		-v HEADER_ROW_NUM="${HEADER_ROW_NUM}" \
		-v INSERT_HEADER_CYCLE="${INSERT_HEADER_CYCLE}"\
		-v FOID_COL_CYCLE="${FOID_COL_CYCLE}" \
		-v DELIMITTER="${DELIMITTER}" \
		-v PREFIX_STR="${PREFIX_STR}"\
		-v SUFFIX_STR="${SUFFIX_STR}"\
		-v NO_DISPLAY_ROW_NUM="${NO_DISPLAY_ROW_NUM}"\
		'
		function make_header(header_line, prefix, suffix, nr){
			return sprintf("%s%s%s", prefix, header_line, suffix)
		}
		function make_line_map(line, line_map, col_cycle, delimiter, rec_num){
			el_list_len = split(line, line_el_list, delimiter)
			elimiter_prefix_regex = "^"delimiter
			insert_times = 1
			new_line = ""
			for(i=1; i<=el_list_len; i++){
				el = line_el_list[i]
				# print "## func el "el
				new_line = sprintf("%s%s%s", new_line, delimiter, el) 
				if(\
					i % col_cycle != 0\
					&& i != el_list_len\
				) continue
				gsub(delimiter_prefix_regex, "", new_line)
				key = sprintf("%s-%s", rec_num, insert_times)
				# print "### fubc key "key
				# print "### func new_line "new_line
				line_map[key] = new_line
				new_line = ""
				insert_times++
			}
		}
		BEGIN{
			if(FOID_COL_CYCLE <= 0 || FOID_COL_CYCLE !~ /^[0-9]+$/) {
				print "FOID_COL_CYCLE must be > 0" > "/dev/stderr"
				exit 1
			}
			if(INSERT_HEADER_CYCLE <= 0 || INSERT_HEADER_CYCLE !~ /^[0-9]+$/) {
				print "INSERT_HEADER_CYCLE must be > 0" > "/dev/stderr"
				exit 1
			}
			ceil = MAX_NF_NUM % FOID_COL_CYCLE 
			ONE_LINE_COL_GROUP_NUM = int(MAX_NF_NUM / FOID_COL_CYCLE )
			if(ceil != 0){
				ONE_LINE_COL_GROUP_NUM++
			}
			# print "ceil "ceil
			# print "MAX_NF_NUM "MAX_NF_NUM
			# print "ONE_LINE_COL_GROUP_NUM "ONE_LINE_COL_GROUP_NUM
			HEADER_LINE_MAP[0] = "" 
			if(HEADER_LINE){
				# prefix_str = gensub("@{NR}", "0", "g", PREFIX_STR)
				# suffix_str = gensub("@{NR}", "0", "g", SUFFIX_STR)
				HEADER_LINE_MAP[0] = ""
				make_line_map(HEADER_LINE, HEADER_LINE_MAP, FOID_COL_CYCLE, DELIMITTER, "h")
				# for(l = 1; l<=ONE_LINE_COL_GROUP_NUM; l++){
				# 	key = sprintf("%s-%s", "h", l)
				# 	print "00 key "key
				# 	print HEADER_LINE_MAP[key] 
				# }
				# exit 
			}
			RECORD_LINE_MAP[0] = ""
			MAX_NR_NUM = 0
		}{
			new_line = ""
			# print "## NF "NF
			for(l=1; l<=NF; l++){
				el = $l
				if(!new_line){
					new_line = el
					continue
				}
				# print "DELIMITTER"DELIMITTER"AA"
				new_line = sprintf("%s%s%s", new_line, DELIMITTER, el)
				# print "## 00 "new_line
			}

			# print "new_line "new_line
			# exit
			make_line_map(new_line, RECORD_LINE_MAP, FOID_COL_CYCLE, DELIMITTER, NR)
			MAX_NR_NUM = NR
		}
		END {
			ceil = MAX_NR_NUM % INSERT_HEADER_CYCLE 
			HEADER_DISPLAY_TIMES= int(MAX_NR_NUM / INSERT_HEADER_CYCLE )
			if(ceil != 0){
				HEADER_DISPLAY_TIMES++
			}
			if(!HEADER_DISPLAY_TIMES){
				HEADER_DISPLAY_TIMES = 1
			}
			# print "MAX_NR_NUM "MAX_NR_NUM
			# print INSERT_HEADER_CYCLE
			# print "HEADER_DISPLAY_TIMES "HEADER_DISPLAY_TIMES
			display_start_index = 0
			for(l = 1; l <= HEADER_DISPLAY_TIMES; l++){
				if(!NO_DISPLAY_ROW_NUM){
					print "Index: "display_start_index + 1
				}
				for(k = 1; k <= ONE_LINE_COL_GROUP_NUM; k++){
					key = sprintf("h-%s", k)
					# print "### head key "key
					header_record = make_header(HEADER_LINE_MAP[key], PREFIX_STR, SUFFIX_STR, l)
					if(header_record){
						print header_record
					}
					for(m = 1; m <= INSERT_HEADER_CYCLE; m++){
						display_row_num = display_start_index + m
						key = sprintf("%s-%s",display_row_num, k)
						# print "## key "key
						record = RECORD_LINE_MAP[key]
						if(!record) continue
						print record
					}
				}
				display_start_index += INSERT_HEADER_CYCLE
			}
		}'
}	
