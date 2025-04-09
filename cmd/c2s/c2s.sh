#!/bin/bash


read_args_for_c2s(){
	local is_already_first_con=0
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--reverse|-r)
			REVERSE="on"
			;;
		--space|-s)
			REPLACE_UNDER_BAR2SPACE="on"
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

display_cut_for_help(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "### Camel case to snake case"
				print ""
				print "[ARG]"
				print "\tArg or stdin"
				print "[Option]"
				print "\t--reverse|-r"
				print "\t\tsnake case to camel case"
				print "\t--space|-s"
				print "\t\treplace underbar to space"
				print "ex1)"
				print "c2s \x22aaBB\x22"
				print ""
				print "->"
				print "aa_bb"
				print "ex2)"
				print "c2s \x22aa_bb\x22"
				print "->"
				print "aaBb"
			}'  | less
			exit 0
	esac
}

cammelToSnake(){
	echo "${CONTENTS}"
	echo --
	echo "${CONTENTS}" \
	| awk \
		-v REPLACE_UNDER_BAR2SPACE="${REPLACE_UNDER_BAR2SPACE}"\
 	'{
		middle_result = "";
		for (i = 1; i <= length($0); i++) {
			char = substr($0, i, 1);
			if (char ~ /[A-Z]/) {
				middle_result = middle_result "_"
			}
			middle_result = middle_result""char;
		}
		gsub(/^_/, "", middle_result)
		result = tolower(middle_result);
		if(!REPLACE_UNDER_BAR2SPACE){
			print result
			next
		}
		gsub(/_/, " ", result)
		print result
	}'

	# | sed -E 's/(.)([A-Z])/\1_\2/g' \
			# | tr '[A-Z]' '[a-z]' \
}

snake2Cammel(){

	echo "${CONTENTS}" \
	| awk \
		-v REPLACE_UNDER_BAR2SPACE="${REPLACE_UNDER_BAR2SPACE}" \
	'{
		if(REPLACE_UNDER_BAR2SPACE){
			gsub(/[ ]+/, "_")
		}
		while (match($0, /_([a-z])/, arr)) {
			replacement = toupper(arr[1]);
			gsub(arr[0], replacement);
		}
		print
	}'
}

c2s_handler(){
	case "${REVERSE}" in
		"") cammelToSnake \
				"${CONTENTS}"
			;;
		*) snake2Cammel \
			"${CONTENTS}"
			;;
	esac
}

