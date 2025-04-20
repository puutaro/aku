
function exec_apl_by_awk(\
	target_str_arg,\
	regex_con,\
	cmd_con,\
	el_list_arg,\
	max_nf_num\
){
	target_str_inner = target_str_arg
	if(target_str_inner !~  regex_con){
		return target_str_inner 
	}
	gsub(/x22/, "\\\x22", target_str_inner)
	echo_cmd = sprintf("echo \x22%s\x22", target_str_inner)
	cmd = sprintf(\
		"%s | %s", \
		echo_cmd, \
		cmd_con\
	)
	for(i=0; i<=max_nf_num;i++){
		# print "max_nf_num "max_nf_num
		# print "i "i
		# print "## el_list_arg "el_list_arg[i]
		gsub(sprintf("@\\{%d\\}",i), el_list_arg[i], cmd)
	}
	last_output=""
	line_num = 1
	while ((cmd | getline output_line) > 0) {
		if(line_num == 1){
			last_output = output_line
		} else {
			last_output = sprintf("%s\n%s", last_output, output_line)
		}
		line_num++
	}
	close(cmd)
	return last_output
} 