#!/bin/bash

display_help_for_aku(){
	awk 'BEGIN {
		print "# Aku"
		print ""
		print "Awk util"
		print ""
		print "## SUB_CMD"
		print ""
		print "### awk"
		print "Set gnu awk path"
		print "Type aku awk -h for more help "
		print ""
		print "### trm"
		print "trm space or etc"
		print "Type aku trim -h for more help "
		print ""
		print "### cut"
		print "cut field"
		print "Type aku cut -h for more help "
		print ""
		print "### rep"
		print "repi by field"
		print "Type aku rep -h for more help "
		print ""
		print "### mch"
		print "match by  field"
		print "Type aku mch -h for more help "
		print ""
		print "### hld"
		print "Ectract str bitween start and end holder by or"
		print "Type aku hld -h for more help "
		print ""
		print "### c2s"
		print "Convert cammel case to snake"
		print "Type aku c2s -h for more help "
		print ""
		print "### if"
		print "give if branch in pipe"
		print "Type aku if -h for more help "
		print ""
		print "### tr"
		print "Total replace"
		print "Type aku tr -h for more help "
		print ""
		print "### uni"
		print "Union variables"
		print "Type aku uni -h for more help "
		print ""
		print "### Up"
		print "to uppercase"
		print "Type aku uni -h for more help "
		print ""
		print "### Sd"
		print "Replace by line"
		print "Type aku sd -h for more help "
		print ""
		print "### Iro"
		print "Coloring by hex string"
		print "Type aku iro -h for more help "
		print ""
	}' | less
}
