#!/bin/bash


read_args_for_hld(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--start-holder|-s)
			START_HOLDER_LIST_CON="${START_HOLDER_LIST_CON}${HOLDER_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--end-holder|-e)
			END_HOLDER_LIST_CON="${END_HOLDER_LIST_CON}${HOLDER_LIST_CON_SEPARATOR}${2}"
			shift
			;;
		--negative|-n)
			ON_NEGATIVE="on"
			;;
		--holder-layout|-l)
			HOLDER_LAYOUT="${2}"
			shift
			;;
		--bound-str|-b)
			BOUND_STR="${2}"	
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
	if [ -n "${ON_NEGATIVE}" ] \
		&& [ -n "${HOLDER_LAYOUT}" ];then
			echo "impossible sametime specify: --on-negative|-n and --holder-layout|-l"
			exit 1	
	fi
}

display_help_for_hld(){
	case "${HELP}" in
		"")
			;;
		*)
			awk 'BEGIN {
				print "## Extract row between start holder and end holder"
				print ""
				print "### [ARG]"
				print "Arg or stdin"
				print "### [Option]"
				print "#### --start-holder|-s"
				print "start holder"
				print "#### --end-holder|-e"
				print "end holder"
				print "- [Ex1] one pair"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e \x22^dd$\x22"
				print ""
				print "->"
				print "aa\nbb\ncc\ndd"
				print ""
				print "- [Ex2] mutiple holder"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e \x22^dd$\x22  -s \x22^ee$\x22 -e \x22^ff$\x22"
				print ""
				print "->"
				print "aa\nbb\ncc\ndd\nee\nff"
				print ""
				print "- [Ex3] duplication holder"
				print "echo \x22aa\nbb\ncc\ndd\nee\nfff\x22 | aku hld -s \x22^aa$\x22 -e \x22^dd$\x22  -s \x22^bb$\x22 -e \x22^ee$\x22"
				print ""
				print "->"
				print "\x22aa\nbb\ncc\ndd\nee"
				print ""
				print "#### --negative|-n"
				print "negative match"
				print "- [Ex1] one pair"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e/x22/^cc$x22 -n"
				print ""
				print "->"
				print "dd\nee\nff"
				print ""
				print "- [Ex2] mutiple holder"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e \x22^cc$\x22  -s \x22^dd$\x22 -e \x22^ee$\x22 -n"
				print ""
				print "->"
				print "ff"
				print ""
				print "- [Ex3] duplication holder"
				print "echo \x22aa\nbb\ncc\ndd\nee\nfff\x22 | aku hld -s \x22^aa$\x22 -e \x22^dd$\x22  \x22^bb$\x22 -e \x22^ee$\x22 -n"
				print ""
				print "->"
				print "ff"
				print ""
				print "#### --holder-layout|-l"
				print "output specify format"
				print "value: "
				print "- start: only start hodler"
				print "- end: only end holder no bound str"
				print "- left: output line with start holder prefix by tab separated"
				print "- blank: normal"
				print "##### this option cannot specify sametime with negative option"
				print ""
				print "- [Ex] start"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e/x22/^cc$x22 -l start"
				print ""
				print "->"
				print "aa\nbb"
				print ""
				print "- [Ex] end"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e/x22/^cc$x22 -l end"
				print ""
				print "->"
				print "bb\ncc"
				print ""
				print "- [Ex] out"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e/x22/^cc$x22 -l out"
				print ""
				print "->"
				print "bb"
				print ""
				print "- [Ex] left"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e/x22/^cc$x22 -l left"
				print ""
				print "->"
				print "aa\tbb\naa\tcc"
				print ""
				print "#### --boudary-str|-b"
				print "put string after end holder "
				print ""
				print "##### this option enable in blank and end layout: becuase of require end holder"
				print ""
				print "- [Ex]"
				print "echo \x22aa\nbb\ncc\ndd\nee\nff\x22 | aku hld -s \x22^aa$\x22 -e/x22/^cc$x22 -b \x22\n\x22"
				print ""
				print "->"
				print "aa\nbb\ncc\n\n"
				print ""
			}' | less
			exit 0
			;;
	esac
}

exec_hld(){
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
	 	-v START_HOLDER_LIST_CON="${START_HOLDER_LIST_CON#${HOLDER_LIST_CON_SEPARATOR}}" \
	 	-v END_HOLDER_LIST_CON="${END_HOLDER_LIST_CON#${HOLDER_LIST_CON_SEPARATOR}}" \
	 	-v HOLDER_LIST_CON_SEPARATOR="${HOLDER_LIST_CON_SEPARATOR}"\
	 	-v ON_NEGATIVE="${ON_NEGATIVE}"\
	 	-v HOLDER_LAYOUT="${HOLDER_LAYOUT}"\
	 	-v BOUND_STR="${BOUND_STR}"\
		' BEGIN{
			# print "## END_HOLDER_LIST_CON: " END_HOLDER_LIST_CON
			# print "## START_HOLDER_LIST_CON: "START_HOLDER_LIST_CON
			holder_list_separator_prefix_re = "^"HOLDER_LIST_CON_SEPARATOR
			holder_list_separator_suffix_re = HOLDER_LIST_CON_SEPARATOR"$"
			blank_el_regex = HOLDER_LIST_CON_SEPARATOR HOLDER_LIST_CON_SEPARATOR
			if(\
				START_HOLDER_LIST_CON ~ holder_list_separator_prefix_re\
				|| START_HOLDER_LIST_CON ~ holder_list_separator_suffix_re\
				|| START_HOLDER_LIST_CON ~ blank_el_regex\
				|| !START_HOLDER_LIST_CON \
				){
					gsub(HOLDER_LIST_CON_SEPARATOR, " | ", START_HOLDER_LIST_CON)
					print "contain blank regex in start holder: "START_HOLDER_LIST_CON  > "/dev/stderr"
					exit 1
				}
			if(\
				END_HOLDER_LIST_CON ~ holder_list_separator_prefix_re\
				|| END_HOLDER_LIST_CON ~ holder_list_separator_suffix_re\
				|| END_HOLDER_LIST_CON ~ blank_el_regex\
				|| !END_HOLDER_LIST_CON \
				){
					gsub(HOLDER_LIST_CON_SEPARATOR, " | ", END_HOLDER_LIST_CON)
					print "contain blank regex in end holder: "END_HOLDER_LIST_CON  > "/dev/stderr"
					exit 1
				}
			START_HOLDER_LIST_LEN = split(START_HOLDER_LIST_CON, START_HOLDER_LIST, HOLDER_LIST_CON_SEPARATOR)
			END_HOLDER_LIST_LEN = split(END_HOLDER_LIST_CON, END_HOLDER_LIST, HOLDER_LIST_CON_SEPARATOR)
			if(\
				START_HOLDER_LIST_LEN != END_HOLDER_LIST_LEN\
			){
				printf (\
					"Unmatch start : end holder num: %d:%d",\
					START_HOLDER_LIST_LEN,\
					END_HOLDER_LIST_LEN\
				)  > "/dev/stderr"
				exit 1
			}
			for (l =1; l<=START_HOLDER_LIST_LEN; l++){
				cur_start_holder_re = START_HOLDER_LIST[l]
				for (k =l + 1; k<=START_HOLDER_LIST_LEN; k++){
					next_start_holder_re = START_HOLDER_LIST[k]
					if(cur_start_holder_re != next_start_holder_re) continue
					printf( "forbidden multiple same start holder name; %s\n", \
						cur_start_holder_re) > "/dev/stderr"
						exit 1
				}
			}
			# for (l =1; l<=START_HOLDER_LIST_LEN; l++){
			# 	cur_end_holder_re = END_HOLDER_LIST[l]
			# 	for (k =l + 1; k<=START_HOLDER_LIST_LEN; k++){
			# 		next_end_holder_re = END_HOLDER_LIST[k]
			# 		if(cur_end_holder_re != next_end_holder_re) continue
			# 		printf( "forbidden multiple same end holder name; %s\n", \
			# 			cur_end_holder_re) > "/dev/stderr"
					# exit
			# 	}
			# }
			for (l =1; l<=START_HOLDER_LIST_LEN; l++){
				cur_start_holder_re = START_HOLDER_LIST[l]
				for (k =1; k<=START_HOLDER_LIST_LEN; k++){
					cur_end_holder_re = END_HOLDER_LIST[k]
					if(cur_start_holder_re != cur_end_holder_re) continue
					printf( "forbidden start holder equal to  end hodler; start: %s, end: %s\n", \
						cur_start_holder_re, cur_end_holder_re)  > "/dev/stderr"
					exit 1
				}
			}
			START_HOLDER_COUNT_MAP[0] = 0
			last_result = ""
			CUR_START_HOLDER_LINE ="" 
	}
	{
		# print "### "$0
		display_switch = 0
		is_start_holder_line = 0
		is_end_holder_line = 0
		# print "## START_HOLDER_COUNT_MAP[1]EE"START_HOLDER_COUNT_MAP[1]
		for (l=1; l <= START_HOLDER_LIST_LEN; l++){
			cur_start_holder_re = START_HOLDER_LIST[l]
			# print "## START_HOLDER_LIST_CON "START_HOLDER_LIST_CON
			# print "## cur_start_holder_re "cur_start_holder_re
			if($0 !~ cur_start_holder_re) continue
			# print "## start match"
			START_HOLDER_COUNT_MAP[l]++
			CUR_START_HOLDER_LINE = $0
			is_start_holder_line++
		}
		for (l=1; l <= START_HOLDER_LIST_LEN; l++){
			# print "## START_HOLDER_COUNT_MAP "l" "START_HOLDER_COUNT_MAP[l]
			# print "## int(START_HOLDER_COUNT_MAP[l]) " int(START_HOLDER_COUNT_MAP[l])
			if(\
				!int(START_HOLDER_COUNT_MAP[l])\
			) continue
			display_switch++
		}
		# print "## display_switch "display_switch
		for (l=1; l <= START_HOLDER_LIST_LEN; l++){
			cur_end_holder_re = END_HOLDER_LIST[l]
			# print "## cur_end_holder_re "cur_end_holder_re"##"
			if($0 !~ cur_end_holder_re) continue
			START_HOLDER_COUNT_MAP[l] = 0
			is_end_holder_line++
		}
		# print "## HOLDER_LAYOUT "HOLDER_LAYOUT
		# print "## is_start_holder_line "is_start_holder_line
		# print "## is_end_holder_line "is_end_holder_line
		# print "## on negative"ON_NEGATIVE
		# print "## before onnegative display_switch"display_switch
		if(!ON_NEGATIVE && !display_switch) {
			next
		}else if(ON_NEGATIVE && display_switch){
			# print "## on negative cancel" display_switch
			next
		}else if(ON_NEGATIVE && !display_switch){
			display_switch = 1
		}
		# print "## 000:display_switch "display_switch
		if(\
			HOLDER_LAYOUT == "left"\
			&& (\
				is_start_holder_line == 0\
				&& is_end_holder_line == 0\
			)\
		){ } else if(\
			HOLDER_LAYOUT == "left"\
		){
			next
		}else if(\
			HOLDER_LAYOUT == "start"\
			&& is_end_holder_line > 0\
			){
			display_switch = 0
		}else if(\
			HOLDER_LAYOUT == "end"\
			&& is_start_holder_line > 0\
		){
			display_switch = 0
		}else if(\
			HOLDER_LAYOUT == "out"\
			&& (\
				is_start_holder_line >0\
				|| is_end_holder_line > 0\
			)\
		){
			display_switch = 0
		}

		# print "## last display_switch"display_switch
		if(!display_switch) next
		if(HOLDER_LAYOUT == "left"){
			print CUR_START_HOLDER_LINE"\t"$0	
		}else {
			print $0
		}
		if(\
			is_end_holder_line\
		) {
			printf BOUND_STR
		}
	}
	'
}

