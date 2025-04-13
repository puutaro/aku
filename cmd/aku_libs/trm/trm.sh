#!/bin/bash


read_args_for_trm(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--delete-prefix|-p)
			DELETE_PREFIXS="${DELETE_PREFIXS}${PREFIX_SEPARATOR}${2}"
			shift
			;;
		--delete-suffix|-s)
			DELETE_SUFFIX="${DELETE_SUFFIX}${PREFIX_SEPARATOR}${2}"
			shift
			;;
		--delete-contain|-c)
			DELETE_CONTAIN="${DELETE_CONTAIN}${PREFIX_SEPARATOR}${2}"
			shift
			;;
		--delete-regex|-r)
			DELETE_REGEX="${DELETE_REGEX}${PREFIX_SEPARATOR}${2}"
			shift
			;;
		--and|-a)
			ON_AND="on"
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
			if [ ${is_already_first_con} -gt 0 ];then 
				TRIM_STR_LIST_CON+="${TRIM_STR_LIST_CON}${TRIM_STR_SEPARATOR}${1:-}"
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
	echo "## arg TRIM_STR_LIST_CON"${TRIM_STR_LIST_CON}
}


display_help_for_trm(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## Trm"
				print "trim space and tab from line"
				print ""
				print "### Arg"
				print ""
				print "- [Ex] trim char"
				print "default is space / tab / zenkaku space"
				print ""
				print "- [Ex] default trim char"
				print "echo \x22 aa \t\x22 | aku trim"
				print ""
				print "->"
				print "aa"
				print ""
				print "-  [Ex] specify char"
				print "aku trim \x22cb \x22 -i \x22cc aa bb cc\x22"
				print ""
				print "->"
				print "aa"
				print ""
				print "- [Ex] specify char by consec"
				print "echo \x22cc aa bb cc\x22 | aku trim \x22c \x22 \x22 \x22 \x22b \x22"
				print ""
				print "->"
				print "aa"
				print ""
				print "### Option"
				print "#### --delete-prefix|-p"
				print "delete prefix line"
				print "- [Ex]"
				print "echo -e \x22aa\nbb\n//cc\n#dd\x22 | aku trim -p \x22#\x22 -p \x22//\x22"
				print ""
				print "->"
				print "aa\nbb\x22"
				print ""
				print "#### --delete-contain|-c"
				print "\t\tdelete contain line"
				print "- [Ex]"
				print "aku trim -i \x22aa\nbb\n//cc\n#dd\x22 -c \x22#\x22 -c \x22bb\x22"
				print ""
				print "->"
				print "aa"
				print ""
				print "#### --delete-suffix|-s"
				print "delete suffix line"
				print "- [Ex]"
				print "echo -e \x22aa\nbbdd\n//cc\n#dd\x22 | aku trim -s \x22dd\x22 -s \x22cc\x22"
				print ""
				print "->"
				print "aa"
				print ""
				print "#### --delete-regex|-p"
				print "tdelete regex line"
				print "- [Ex]"
				print "aku trim \x22aa\nbb\n//cc\n#dd\x22 -r \x22.*cc.*\x22 -r \x22.*bb.*\x22"
				print ""
				print "->"
				print "aa"
				print "#### --and|-a"
				print "and condition"
				print "* This also apply to between regexs and contains"
				print "- [Ex1]"
				print "aku trim -i \x22aa\ncbb\n//ccbb\n#caabb\x22 -p \x22c\x22 -s \x22bb\x22 -a"
				print ""
				print "->"
				print "aa"
				print ""
				print "- [Ex2] contain \x22and\x22"
				print "aku trim -i \x22aa\ncbb\n//ccabsedsbb\n#caaabsedsbb\x22 -c \x22abs\x22 -c \x22ads\x22 -a"
				print ""
				print "->"
				print "aa"
				print "- [Ex2] contain and regex \x22and\x22"
				print "aku trim -i \x22aa\ncbb\n//ccabsedsbb\n#caaabsedsbb\x22 -r \x22.*abs.*\x22 -c \x22ads\x22 -a"
				print ""
				print "->"
				print "aa"
			}' | less
			exit 0
			;;
	esac
}
exec_trm(){
	echo "${CONTENTS}"\
	 | ${AWK_PATH} \
	 	-v TRIM_STR_LIST_CON="${TRIM_STR_LIST_CON#${TRIM_STR_SEPARATOR}}"\
	 	-v TRIM_STR_SEPARATOR="${TRIM_STR_SEPARATOR}" \
	 	-v DELETE_PREFIXS="${DELETE_PREFIXS#${PREFIX_SEPARATOR}}" \
	 	-v DELETE_SUFFIX="${DELETE_SUFFIX#${PREFIX_SEPARATOR}}" \
	 	-v DELETE_CONTAIN="${DELETE_CONTAIN#${PREFIX_SEPARATOR}}" \
	 	-v DELETE_REGEX="${DELETE_REGEX#${PREFIX_SEPARATOR}}" \
	 	-v ON_AND="${ON_AND}" \
	 	-v PREFIX_SEPARATOR="${PREFIX_SEPARATOR}" \
	 	'
		 BEGIN {
		 	TRIM_STR_LIST_LEN = split(TRIM_STR_LIST_CON, TRIM_STR_LIST, TRIM_STR_SEPARATOR)
			if(!TRIM_STR_LIST_LEN){
				print "## TRIM_STR_LIST_LEN"TRIM_STR_LIST_LEN
				TRIM_STR_LIST_LEN = 1
				TRIM_STR_LIST[1] = ""
			}
			print "## TRIM_STR_LIST_LEN"TRIM_STR_LIST_LEN
			print "## TRIM_STR_LIST[1] "TRIM_STR_LIST[1]
		 	total_and_count = 0
		 	delete_prefix_list_len = split(DELETE_PREFIXS , delete_prefix_list, PREFIX_SEPARATOR)
		 	if(delete_prefix_list_len > 0) {
		 		total_and_count++
		 	}
		 	delete_suffix_list_len = split(DELETE_SUFFIX , delete_suffix_list, PREFIX_SEPARATOR)
		 	if(delete_suffix_list_len > 0) {
		 		total_and_count++
		 	}
		 	delete_contain_list_len = split(DELETE_CONTAIN , delete_contain_list, PREFIX_SEPARATOR)
		 	if(delete_contain_list_len > 0) {
		 		total_and_count++
		 	}
		 	delete_regex_list_len = split(DELETE_REGEX , delete_regex_list, PREFIX_SEPARATOR)
		 	if(delete_regex_list_len > 0) {
		 		total_and_count++
		 	}
		 }
		 {
		 	for(l=1; l <= TRIM_STR_LIST_LEN; l++){
		 		regex_src_str = TRIM_STR_LIST[l]
		 		if(!regex_src_str){
		 			print "## not"
		 			regex_src_str = "\t 　"
		 		}
		 		print "## regex_src_str"regex_src_str"AA"
		 		trim_regex_con = sprintf("[%s]+", regex_src_str)
		 		prefix_trim_regex_con = sprintf("^%s", trim_regex_con)
		 		suffix_trim_regex_con = sprintf("%s$", trim_regex_con)
		 		print "## prefix_trim_regex_con "prefix_trim_regex_con
		 		print "## suffix_trim_regex_con "suffix_trim_regex_con
		 		gsub(prefix_trim_regex_con, "", $0)
		 		gsub(suffix_trim_regex_con, "", $0)
		 	}
			# gsub(/^[ \t]+/, "", $0)
			# gsub(/[ \t]+$/, "", $0)
			if(!$0) next
			enable_prefix = 0
			for(i=1;i<=delete_prefix_list_len;i++){
				delete_prefix = sprintf("^%s", delete_prefix_list[i])
				if(!delete_prefix) continue
				if($0 !~ delete_prefix) continue
				enable_prefix = 1
			}
			enable_suffix = 0
			for(i=1;i<=delete_suffix_list_len;i++){
				delete_suffix = sprintf("%s$", delete_suffix_list[i])
				if(!delete_suffix) continue
				if($0 !~ delete_suffix) continue
				enable_suffix = 1
			}
			contain_count = 0
			enable_contain = 0
			for(i=1;i<=delete_contain_list_len;i++){
				delete_contain = sprintf("%s", delete_contain_list[i])
				if(!delete_contain) continue
				if($0 !~ delete_contain) continue
				contain_count++
				enable_contain = 1
			}
			regex_count = 0
			enable_regex = 0
			for(i=1;i<=delete_regex_list_len;i++){
				delete_regex = sprintf("%s", delete_regex_list[i])
				if(!delete_regex) continue
				if($0 !~ delete_regex) continue
				regex_count++
				enable_regex = 1
			}
			cur_total_enable_count = \
				enable_prefix + enable_suffix + enable_contain + enable_regex
			if(\
				!ON_AND \
				&& cur_total_enable_count > 0\
			){
					next
			}
			if(\
				ON_AND \
				&& cur_total_enable_count == total_and_count\
				&& contain_count == delete_contain_list_len \
				&& regex_count == delete_regex_list_len \
			) {
					next
			}
			print $0
		}'
}

