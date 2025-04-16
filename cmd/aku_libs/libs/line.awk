

function make_line_by_delimiter(new_line, el, delimiter){
	if(!new_line){
		return el
	} 
	new_line = sprintf("%s%s%s", new_line, delimiter, el)
	delimitter_prefix_regex = "^"delimiter
	# gsub(delimiter_prefix_regex, "", new_line)
	# print "## 00 "new_line
	return new_line
}