#!/bin/bash


read_args_for_awk(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
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

display_help_for_awk(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "Awk"
				print "## Set awk path"
				print ""
				print ""
				print "### ARG"
				print "${awk path}"
				print "register awk path"
				print ""
				print "-"
				print "remove register awk path"
				print ""
				print "(blank)"
				print "show register awk path"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_awk(){
	case "${CONTENTS}" in
		"")
			echo "${AWK_PATH}"	
			;;
		"-")
			echo "delete custom awk path"
			rm "${AWK_CMD_TXT_PATH}" 
			;;
		*)
			echo "${CONTENTS}" > ${AWK_CMD_TXT_PATH}
			;;
	esac	
}
