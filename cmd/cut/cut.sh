#!/bin/bash


read_args_for_cut(){
	local STR=""
	while (( $# > 0 ))
	do
	case "${1}" in
		--help|-h)
			HELP="${1}"
			;;
		--field-num|-f)
			FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON}${FIELD_NUM_SEPARATOR}${2}"
			;;
		--delimitter|-d)
			DELIMITTER="${2}"
			;;
		--output-delimiter|-o)
			OUTPUT_DELIMITER="${2}"
			;;
		-*)
			echo "no option: ${1}"
			exit 1
			;;
		*)	
			CONTENTS+="${1:-}"
			;;
	esac
	shift
	done <<- END
	$STR
	END
	if [ -p /dev/stdin ]; then
	    CONTENTS="$(cat)"
	fi
	case "${DELIMITTER}" in
		"") DELIMITTER=" "
			;;
	esac
	case "${OUTPUT_DELIMITER}" in
		"") OUTPUT_DELIMITER="\t"
			;;
	esac
}

display_cut_for_help(){
	case "${HELP}" in
		"");;
		*)
			awk 'BEGIN {
				print "### cut field by awk spec"
				print ""
				print "[ARG]"
				print "\tArg or stdin"
				print "[Option]"
				print "\t--field-num|-f"
				print "\t\ttarge field"
				print "[Ex1] single field"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x222\x22 | aku cut"
				print ""
				print "->"
				print "bb"
				print ""
				print "[Ex2] multiple field"
				print "echo \x22aa    bb   cc    #dd\x22 | aku cut -f \x221\x22 -f \x223-4\x22"
				print ""
				print "->"
				print "aa\tcc\t#dd"
				print ""
				print "\t--delimitter|-d"
				print "\t\tdelimitter (default is space)"
				print "[Ex1] string delimitter"
				print "echo \x22aaAAAbbAAAccAAA#dd\x22 | aku cut -f \x222\x22 -d \x2AAA\x22"
				print ""
				print "->"
				print "bb"
				print ""
				print "[Ex2] consec space delimiter"
				print "echo \x22aa  bb     cc      #dd\x22 | aku cut -f \x222\x22 -d \x22 \x22"
				print ""
				print "->"
				print "bb"
				print ""
				print "\t--output-delimiter|-o"
				print "\t\toutput delimiter (deafult is tab)"
				print "[Ex]"
				print "echo \x22aa  bb     cc      #dd\x22 | aku cut -f \x222-3\x22 -o \x22 \x22"
				print ""
				print "->"
				print "bb cc"
				print ""
			}' | less
			exit 0
			;;
	esac
}
exec_cut(){
	local contain_num_separator=","
	echo "${CONTENTS}"\
	| awk \
		-F "${DELIMITTER}" \
	 	-v FIELD_NUM_LIST_CON="${FIELD_NUM_LIST_CON#${FIELD_NUM_SEPARATOR}}" \
	 	-v FIELD_NUM_SEPARATOR="${FIELD_NUM_SEPARATOR}" \
	 	-v DELIMITTER="${DELIMITTER}"\
	 	-v OUTPUT_DELIMITER="${OUTPUT_DELIMITER}"\
	 	-v contain_num_separator="${contain_num_separator}"\
		'function convert_nums_by_compa(nums_con){
			max_nf = 10
			output = ""
			if (nums_con ~ /^0$/) {
				for (i = 1; i <= max_nf; i++) {
				    output = sprintf("%s%s%s", output,contain_num_separator, i)
				}
				return output
			}
			if( nums_con ~ /^[0-9]+$/ ){
		  		return sprintf("%s%s", nums_con, contain_num_separator)
			}
			if (nums_con ~ /^[0-9]+-[0-9]+$/) {
			    split(nums_con, parts, "-")
			    start = parts[1]
			    end = parts[2]
			    for (i = int(start); i <= int(end); i++) {
			        output = sprintf("%s%s%s", output, contain_num_separator, i)
			    }
			    return output
			  }
			if (nums_con ~ /^[0-9]+-$/) {
				start = substr(nums_con, 1, length(nums_con) - 1)
				for (i = int(start); i <= max_nf; i++) {
				    output = sprintf("%s%s%s", output,contain_num_separator, i)
				}
				return output
			}
		  	printf( "contain no number in --field-num|-f arg: %s\n", nums_con)
		  	exit
		}
		BEGIN{
			field_num_list_len = split(FIELD_NUM_LIST_CON, field_num_list, FIELD_NUM_SEPARATOR)
			display_field_num_con = ""
			for(l=1; l <= field_num_list_len; l++){
				field_num_con = field_num_list[l]
				display_field_num_con = sprintf(\
					"%s%s%s",
					display_field_num_con,\
					contain_num_separator,
					convert_nums_by_compa(field_num_con))
			}
			gsub(/,+/, ",", display_field_num_con)
			last_output = ""
		}
	{
		line = ""
		for(l=1;l<=NF;l++){
			match_field_num = sprintf("%s,", l)
			if(\
				display_field_num_con !~ match_field_num\
			) continue
			if(l == NF){
				line = sprintf("%s%s", line, $l)
				continue
			}
			line = sprintf("%s%s%s",line, $l, OUTPUT_DELIMITER)
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