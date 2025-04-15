#!/bin/bash


read_args_for_if(){
	local count_arg_input=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
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
			if [ ${count_arg_input} -eq 1  ];then
				REGEX_CON="${1:-}"
			elif [ ${count_arg_input} -ge 2 ]; then
				CMD_CON="${CMD_CON}${ARG_SEPARATOR}${1:-}"
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
	elif [ -z "${HELP}" ]; then
		echo "no stdin" 1>&2
		exit 1
	fi
	if [ -z "${HELP}" ] \
		&& [ -z "${REGEX_CON}" ];then
		echo "first arg (match regex) not exist"
		exit 1
	fi
	if [ -z "${HELP}" ] \
		&& [ -z "${CMD_CON}" ];then
		echo "second arg (cmd) not exist"
		exit 1
	fi
}

display_help_for_if(){
	case "${HELP}" in
		"")
			;;
		*)
			awk 'BEGIN {
				print "## If"
				print ""
				print "give if branch in pipe"
				print ""
				print "### ARG"
				print ""
				print "Arg"
				print ""
				print "#### first arg"
				print ""
				print "if condition regex"
				print ""
				print "#### second arg"
				print ""
				print "proc cmd"
				print ""
				print "- default first cmd: echo \x22${0}\x22"
				print ""
				print "- @{0}, @{1}, @{2}.. to $0, $1, $2..  in awk"
				print ""
				print "- Ex confition for stdout"
				print ""
				print "echo \x22aa\nbb\x22 | aku if  \x22aa\x22 \x22sed \x27s/^/PREFIX/\x27\x22"
				print ""
				print "->"
				print "PREFIXaa\nbb"
				print ""
				print "- Ex confition for proc"
				print ""
				print "echo \x22aa\nbb\x22 | aku if  \x22aa\x22 \x22touch @{0}; echo @{0}\x22"
				print ""
			}' | less
			exit 0
			;;
	esac
}

exec_if(){
	local max_nf_num=$(\
		echo "${CONTENTS}" \
		| awk  -F "${DELIMITTER}" '{print NF; exit}'\
	)
	echo "${CONTENTS}"\
	| ${AWK_PATH} \
		-F "${DELIMITTER}" \
		-v max_nf_num="${max_nf_num}"\
		-v REGEX_CON="${REGEX_CON}"\
		-v CMD_CON="${CMD_CON}"\
	'{
		# print "$0 "$0
		if($0 !~ REGEX_CON){
			print $0
			next
		}
		gsub(/x22/, "\\\x22", $0)
		echo_cmd = sprintf("echo \x22%s\x22", $0)
		cmd = sprintf(\
			"%s | %s", \
			echo_cmd, \
			CMD_CON\
		)
		for(l=0; l<=max_nf_num;l++){
			gsub(sprintf("@\\{%d\\}",l), $l, cmd)
		}
		cmd | getline output
		# exit_status = (cmd | getline output)
		# print "cmd "cmd
		# if(exit_status == 0){
		# 	print "aku if err: " > "/dev/stderr"
		# 	exit 1
		# }
		print output
		close(cmd)
	}'
}
