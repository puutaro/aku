#!/bin/bash


read_args_for_up(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--position|-p)
			POSITION=${2}
			shift
			;;
		--lower|-l)
			FUNC_NAME="tolower"
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


display_help_for_up(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Up"
				print ""
				print "to uppercase"
				print ""
				print ""
				print "### Arg"
				print ""
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22aa\x22"
				print "->"
				print "AA"
				print "```sh.sh"
				print ""
				print "### Option"
				print ""
				print ""
				print "#### --position|-p"
				print ""
				print "specify position"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22aaaa\x22 -p 1"
				print "->"
				print "Aaaa"
				print "```"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22aaaa\x22 -p 2-4"
				print "->"
				print "aAAA"
				print "```"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22aaaa\x22 -p 1"
				print "->"
				print "Aaaa"
				print "```"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22aaaa\x22 -p 2-4"
				print "->"
				print "aAAA"
				print "```"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22aaaa\x22 -p -3"
				print "->"
				print "AAAa"
				print "```"
				print ""
				print "#### --lower|-l"
				print ""
				print "- Ex"
				print ""
				print "```sh.sh"
				print "aku up \x22AAAA\x22 -l -3"
				print "->"
				print "aaaA"
				print "```"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_up(){
	local CONTAIN_NUM_SEPARATOR=","
	echo "${CONTENTS}"\
	 | ${AWK_PATH} \
		-i "${AWK_LIST_FUNCS_PATH}"\
	 	-v POSITION="${POSITION}"\
	 	-v CONTAIN_NUM_SEPARATOR="${CONTAIN_NUM_SEPARATOR}"\
	 	-v FUNC_NAME="${FUNC_NAME}"\
		'function downcase(str, pos) {
		  # pos番目の文字が存在する場合のみ処理を行う
		  if (pos <= length(str)) {
	    # pos番目より前の文字列
	    pre = substr(str, 1, pos - 1)
	    # pos番目の文字を小文字に変換
	    char = '${FUNC_NAME}'(substr(str, pos, 1))
	    # pos番目より後の文字列
	    post = substr(str, pos + 1)
	    # 連結して返す
	    return pre char post
	  } else {
	    return str # pos が文字列長より大きい場合は元の文字列を返す
	  }
	}
	{
	if(POSITION == ""){
		print '${FUNC_NAME}'($0)
		next
	}
	num_list_con = convert_nums_by_compa(POSITION, length($0), CONTAIN_NUM_SEPARATOR)
	CONTAIN_NUM_SEPARATOR_PREFIX_REGEX = "^"CONTAIN_NUM_SEPARATOR
	CONTAIN_NUM_SEPARATOR_SUFFIX_REGEX = CONTAIN_NUM_SEPARATOR"$"
	CONTAIN_NUM_SEPARATOR_CONSEC_REGEX = sprintf("[%s]+", CONTAIN_NUM_SEPARATOR)
	gsub(CONTAIN_NUM_SEPARATOR_PREFIX_REGEX, "", num_list_con)
	gsub(CONTAIN_NUM_SEPARATOR_SUFFIX_REGEX, "", num_list_con)
	gsub(CONTAIN_NUM_SEPARATOR_CONSEC_REGEX, CONTAIN_NUM_SEPARATOR, num_list_con)
	num_list_len = split(num_list_con, num_list, CONTAIN_NUM_SEPARATOR)
	result_str = $0
	for(l=1; l<= num_list_len; l++){
		cur_num = num_list[l]
		result_str = downcase(result_str, cur_num)
	}
	print result_str
	exit
	if(POSITION ~ /^[0-9]+$/){
		print "POSITION "POSITION 
		print downcase($0, POSITION)
		next
	}else {
		print "position must be number: "POSITION > "/dev/stderr"
		exit 1
	}
}'
}


