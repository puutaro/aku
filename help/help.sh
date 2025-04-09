#!/bin/bash

display_help_for_aku(){
	awk 'BEGIN {
		print "### awk util"
		print ""
		print "[SUB_CMD]"
		print "## trim"
		print "\ttrim space or etc"
		print "\tType aku trim -h for more help "
		print ""
		print "## cut"
		print "\ttcut field"
		print "\tType aku cut -h for more help "
	}' | less
}
