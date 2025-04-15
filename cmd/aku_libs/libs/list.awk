function convert_nums_by_compa(nums_con, max_num, separator){
	output = ""
	if (\
		nums_con ~ /^0$/\
		|| !nums_con\
	) {
		for (i = 1; i <= max_num; i++) {
		    output = sprintf("%s%s%s", output,separator, i)
		}
		return output
	}
	if( nums_con ~ /^[0-9]+$/ ){
  		return sprintf("%s%s", nums_con, separator)
	}
	if (nums_con ~ /^-[0-9]+$/) {
	    split(nums_con, parts, "-")
	    start = 1 
	    end = parts[2]
	    for (i = int(start); i <= int(end); i++) {
	        output = sprintf("%s%s%s", output, separator, i)
	    }
	    return output
	  }
	if (nums_con ~ /^[0-9]+-[0-9]+$/) {
	    split(nums_con, parts, "-")
	    start = parts[1]
	    end = parts[2]
	    for (i = int(start); i <= int(end); i++) {
	        output = sprintf("%s%s%s", output, separator, i)
	    }
	    return output
	  }
	if (nums_con ~ /^[0-9]+-$/) {
		start = substr(nums_con, 1, length(nums_con) - 1)
		for (i = int(start); i <= max_num; i++) {
		    output = sprintf("%s%s%s", output,separator, i)
		}
		return output
	}
  	printf( "contain no number in --field-num|-f arg: %s\n", nums_con) > "/dev/stderr"
  	exit 1 
}
function make_list_from_muti_list_con(lists_con, max_num, list_separator, el_separator){
	lists_len = split(lists_con, list, list_separator)
	new_list_con = ""
	for(l=1; l <= lists_len; l++){
		el = list[l]
		new_list_con = sprintf(\
			"%s%s%s",
			new_list_con,\
			el_separator,
			convert_nums_by_compa(el, max_num, el_separator))
	}
	consec_separator_regex = el_separator"+"
	gsub(consec_separator_regex, el_separator, new_list_con)
	return new_list_con
}
function sort_list_con(list_con, separator) {
	# 配列を値で数値として昇順にソート (GNU awk拡張)
	list_len = split(list_con, list, separator)
	new_list_con = ""
	PROCINFO["sorted_in"] = "@val_num_asc"
	for (i in list) {
		el = list[i]
		if(!new_list_con){
			new_list_con = el
			continue
		}
		new_list_con = sprintf("%s%s%s", new_list_con, separator, el)
	}
	PROCINFO["sorted_in"] = ""
	return new_list_con
}
function trim_separator(list_con, separator){
	contain_num_separator_prefix_regex = "^"separator
	contain_num_separator_suffix_regex = separator"$"
	contain_num_separator_consec_regex = sprintf("[%s]+", separator)
	gsub(contain_num_separator_prefix_regex, "", list_con)
	gsub(contain_num_separator_suffix_regex, "", list_con)
	gsub(contain_num_separator_consec_regex, separator, list_con)
	return list_con
}
function remove_dup_el(list_con,  separator) {
	list_len = split(list_con, list, separator)
	new_list_con = "" 
	for (i in list) {
		el = list[i]
		# print "el "el
	if (seen[el]) continue 
	seen[el]++
		if(!new_list_con){
			new_list_con = el
			continue
		}
		new_list_con = sprintf("%s%s%s", new_list_con, separator, el)
	}
	delete seen # seen配列を削除。
	return new_list_con
}		
