# aku

Util by awk for Linux

Table of Sub cmd
-----------------
<!-- vim-markdown-toc GFM -->

* [Install](#install)
* [SUB_CMD](#sub_cmd)
    * [Trim](#trim)
    * [Cut](#cut)
    * [C2s](#c2s)
    * [Mch](#mch)
   

## Install

```
curl https://raw.githubusercontent.com/puutaro/aku/refs/heads/master/install.sh | sudo bash

```

## SUB_CMD

### Trim

trim space and tab from line

#### [ARG]
#### Arg or stdin
#### [Option]

#### --delete-prefix|-p
		delete prefix line
- [Ex]

```sh.sh
aku trim "aa
bb
//cc
#dd" -p "#" -p "//"

->
aa
bb"

```

#### --delete-contain|-c
		delete contain line


- [Ex]

```sh.sh
aku trim "aa
bb
//cc
#dd" -c "#" -c "bb"

->
aa
```

#### --delete-suffix|-s
		delete suffix line


- [Ex]

```sh.sh
aku trim "aa
bbdd
//cc
#dd" -s "dd" -s "cc"

->
aa
```

#### --delete-regex|-p
		delete regex line


- [Ex]

```sh.sh
aku trim "aa
bb
//cc
#dd" -r ".*cc.*" -r ".*bb.*"

->
aa
```

#### --and|-a
		and condition
		* This also apply to between regexs and contains


- [Ex1]

```sh.sh
aku trim "aa
cbb
//ccbb
#caabb" -p "c" -s "bb" -a

->
aa
```

- [Ex2] contain "and"

```sh.sh
aku trim "aa
cbb
//ccabsedsbb
#caaabsedsbb" -c "abs" -c "ads" -a

->
aa
```

- [Ex2] contain and regex "and"
aku trim "aa
cbb
//ccabsedsbb
#caaabsedsbb" -r ".*abs.*" -c "ads" -a

->
aa
```

### Cut

Cut field by awk spec

### [ARG]
	Arg or stdin
### [Option]

#### --field-num|-f
		targe field

- [Ex1] single field

```
echo "aa    bb   cc    #dd" | aku cut -f "2" | aku cut

->
bb
```

- [Ex2] multiple field

```sh.sh
echo "aa    bb   cc    #dd" | aku cut -f "1" -f "3-4"

->
aa	cc	#dd

### --delimitter|-d
		delimitter (default is space)
- [Ex1] string delimitter
echo "aaAAAbbAAAccAAA#dd" | aku cut -f "2" -d *AA"

->
bb
```

- [Ex2] consec space delimiter

```sh.sh
echo "aa  bb     cc      #dd" | aku cut -f "2" -d " "

->
bb
```

#### --output-delimiter|-o
		output delimiter (deafult is tab)

- [Ex]

```sh.sh
echo "aa  bb     cc      #dd" | aku cut -f "2-3" -o " "

->
bb cc

```

- [Ex4] multiple field by end range

```sh.sh
echo "aa    bb   cc    #dd" | aku cut -f "1" -f "2-"

->
bb	cc	#dd
kkkkk
```

#### --row-num|-r
		target row (default: all)
- [Ex1] single row

```sh.sh
echo ~" | aku cut -r "2" | aku cut
```

- [Ex2] multiple row

```sh.sh
echo "~" | aku cut -r "1" -r "3-4"
```

- [Ex3] multiple row by end range

```sh.sh
echo "~" | aku cut -r "1" -r "-4"
```


### C2s

Cammel case to snake case 

#### ARG

Arg or stdin

#### Option

#### --reverse|-r

snake case to camel case

#### --space|-s

replace underbar to space

- Ex1

```sh.sh
c2s "aaBB"

->
aa_bb

```

- Ex2

```sh.sh
c2s "aa_bb"
->
aaBb

```

### Mch

This is Matcher.
As feature, enable matching to field by regex


### [ARG]

 Arg or stdin
 
### [Option]

#### --field-num-to-regex|-f

target field to regex

- [Ex1] single field

```sh.sh
echo "aa bb cc #dd" | aku mch -f "1:^aa$"

->
aa bb cc #dd
```

- [Ex2] multiple field

```sh.sh
echo "aa bb cc #dd" | aku mch -f "1:^aa$" -f "3-4:.*"

->
aa bb cc #dd
```

- [Ex3] multiple field by end range
  
```sh.sh
echo "aa bb cc #dd" | aku mch -f "1:^aa$" -f "-4:.*"

->
aa bb cc #dd
```

- [Ex4] multiple field by end range

```sh.sh
echo "aa bb cc #dd" | aku mch -f "1:^aa$" -f "2-:.*"

->
aa bb cc #dd
```

#### --negative-field-num-to-regex|-n
                negative target field to regex
		
- [Ex1] single negative field

```sh.sh
echo "aa bb cc #dd" | aku mch -n "1:^cc$"

->
aa bb cc #dd
```

- [Ex2] multiple negative field

```sh.sh
echo "aa bb cc #dd" | aku mch -n "1:^cc$" -n "3-4:tt"

->
aa bb cc #dd
```

- [Ex3] multiple negative field by end range

```sh.sh
echo "aa bb cc #dd" | aku mch -n "1:^rr$" -n "-4:tt"

->
aa bb cc #dd
```

- [Ex4] multiple negative field by end range

```sh.sh
echo "aa bb cc #dd" | aku mch -f "1:^rr$" -f "2-:ttx22

->
aa bb cc #dd
```

#### --delimitter|-d

 delimitter (default is space)

- [Ex1] string delimitter

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku cut -f "2:bb" -d *AA"

->
aaAAAbbAAAccAAA#dd
```

#### --and|-a

enable and match

- [Ex]

```sh.sh
echo "aa bb cc #dd" | aku mch -n "1:^bb$" -f "1:^aa$" -a

->
aa bb cc #dd
```

