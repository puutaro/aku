#!/bin/bash


read_args_for_trim(){
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
	fi
}


display_trim_for_help(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "## trim space and tab from line"
				print ""
				print "### [ARG]"
				print "### \tArg or stdin"
				print "### [Option]"
				print "\t--delete-prefix|-p"
				print "\t\tdelete prefix line"
				print "#### [Ex]"
				print "aku trim \x22aa\nbb\n//cc\n#dd\x22 -p \x22#\x22 -p \x22//\x22"
				print ""
				print "->"
				print "aa\nbb\x22"
				print ""
				print "\t--delete-contain|-c"
				print "\t\tdelete contain line"
				print "#### [Ex]"
				print "aku trim \x22aa\nbb\n//cc\n#dd\x22 -c \x22#\x22 -c \x22bb\x22"
				print ""
				print "->"
				print "aa"
				print ""
				print "\t--delete-suffix|-s"
				print "\t\tdelete suffix line"
				print "#### [Ex]"
				print "aku trim \x22aa\nbbdd\n//cc\n#dd\x22 -s \x22dd\x22 -s \x22cc\x22"
				print ""
				print "->"
				print "aa"
				print ""
				print "\t--delete-regex|-p"
				print "\t\tdelete regex line"
				print "#### [Ex]"
				print "aku trim \x22aa\nbb\n//cc\n#dd\x22 -r \x22.*cc.*\x22 -r \x22.*bb.*\x22"
				print ""
				print "->"
				print "aa"
				print "\t--and|-a"
				print "\t\tand condition"
				print "\t\t* This also apply to between regexs and contains"
				print "#### [Ex1]"
				print "aku trim \x22aa\ncbb\n//ccbb\n#caabb\x22 -p \x22c\x22 -s \x22bb\x22 -a"
				print ""
				print "->"
				print "aa"
				print ""
				print "####[Ex2] contain \x22and\x22"
				print "aku trim \x22aa\ncbb\n//ccabsedsbb\n#caaabsedsbb\x22 -c \x22abs\x22 -c \x22ads\x22 -a"
				print ""
				print "->"
				print "aa"
				print "####[Ex2] contain and regex \x22and\x22"
				print "aku trim \x22aa\ncbb\n//ccabsedsbb\n#caaabsedsbb\x22 -r \x22.*abs.*\x22 -c \x22ads\x22 -a"
				print ""
				print "->"
				print "aa"
			}' | less
			exit 0
			;;
	esac
}
exec_trim(){
	echo "${CONTENTS}"\
	 | awk \
	 	-v DELETE_PREFIXS="${DELETE_PREFIXS#${PREFIX_SEPARATOR}}" \
	 	-v DELETE_SUFFIX="${DELETE_SUFFIX#${PREFIX_SEPARATOR}}" \
	 	-v DELETE_CONTAIN="${DELETE_CONTAIN#${PREFIX_SEPARATOR}}" \
	 	-v DELETE_REGEX="${DELETE_REGEX#${PREFIX_SEPARATOR}}" \
	 	-v ON_AND="${ON_AND}" \
	 	-v PREFIX_SEPARATOR="${PREFIX_SEPARATOR}" \
	 	'
		 BEGIN {
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
				gsub(/^[ \t]+/, "", $0)
				gsub(/[ \t]+$/, "", $0)
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

