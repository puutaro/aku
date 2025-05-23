# aku

Util by awk for Linux

Table of Sub cmd
-----------------
<!-- vim-markdown-toc GFM -->

* [Install or update](#install-or-update)
* [Uninstall](#uninstall)
* [SUB_CMD](#sub_cmd)
    * [Awk](#awk)
    * [Trim](#trim)
    * [Cut](#cut)
    * [C2s](#c2s)
    * [Mch](#mch)
    * [Rep](#rep)
    * [Hld](#hld)
    * [Up](#up)
		* [Apl](#apl)
		* [Tr](#tr)
		* [Uni](#uni)
		* [Fld](#fld)
		* [Sd](#sd)
		* [Iro][#iro]

## Install or update

```
curl https://raw.githubusercontent.com/puutaro/aku/refs/heads/master/install.sh | sudo bash

```

## Uninstall

```sh.sh

sudo rm /usr/local/bin/aku \
&& sudo rm -rf /usr/local/bin/aku_libs

```

- gnu awk require, set gnu awk path by bellow [awk sub cmd](#awk)


## SUB_CMD

### Awk

Set awk path

#### [ARG]

- `${awk path}`

register awk path

- `-`

remove register awk path

- `(blank)`

show register awk path

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

```sh.sh
aku trim "aa
cbb
//ccabsedsbb
#caaabsedsbb" -r ".*abs.*" -c "ads" -a

->
aa
```

## Cut
Cut field by awk spec

### ARG

Arg or stdin

### Option

#### --field-num|-f

target field

- Ex single field (default: all)

```sh.sh
echo "aa    bb   cc    #dd" | aku cut -f "2"

->
bb
```

- Ex multiple field

```sh.sh
echo "aa    bb   cc    #dd" | aku cut -f "1" -f "3-4"

->
aa	cc	#dd
```

- Ex multiple field by end range

```sh.sh
echo "aa    bb   cc    #dd" | aku cut -f "1" -f "-4"

->
aa	bb	cc	#dd
```

- Ex multiple field by end range

```sh.sh
echo "aa    bb   cc    #dd" | aku cut -f "1" -f "2-"

->
bb	cc	#dd
```

#### --row-num|-r

target row (default: all)

- Ex single row

```sh.sh
echo ~" | aku cut -r "2" | aku cut
```

- Ex multiple row

```sh.sh
echo "~" | aku cut -r "1" -r "3-4"
```

- Ex multiple row by end range

```sh.sh
echo "~" | aku cut -r "1" -r "-4"
```

#### --delimitter|-d

delimitter (default is space)

- Ex string delimitter

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku cut -f "2" -d *AA"
```

->
bb
```

- Ex consec space delimiter

```sh.sh
echo "aa  bb     cc      #dd" | aku cut -f "2" -d " "

->
bb
```

#### --on-negative|-n

negative cut

- Ex

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku cut -n -f "2" -d *AA"

->
aaAAAccAAA#dd
```


## C2s

Cammel case to snake case 

### ARG

Arg or stdin

### Option

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

## Mch

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
## Rep

Replace field

### ARG

Arg or stdin

#### first arg

target field to remove regex

- format -> fieild num:regex

- Ex1 single field

```sh.sh
echo "aa1 bb cc #dd" | aku rep "1:^aa"

->
1 bb cc #dd
```

- Ex3 by end range

```sh.sh
echo "aa bb cc #dd" | aku rep "-4:^[a-z]"

->
a b c #dd
```

- Ex4 by end range

```sh.sh
echo "aa bb cc #dd" | aku rep "2-:^[a-z]"

->
aa b c #dd
```

#### second arg

- format -> fieild num:regex

replace first arg field to str with remove regex

- Ex1 single field

```sh.sh
echo "aa bb cc #dd" | aku rep "1:^[a-z]" "1:CC"

->
CCa bb cc #dd
```

- Ex2 by range

```sh.sh
echo "aa bb cc #dd" | aku rep "2-:^[a-z]" "3-4:CC"

->
aa b CCc #dd
```

- Ex3 by end range

```sh.sh
echo "aa bb cc #dd" | aku rep "2:^[a-z]" "-4:CC"

->
aa UUb cc #dd
```

- Ex4 by end range

```sh.sh
echo "aa bb cc #dd" | aku rep "3:[a-z]$" "2-:TTx22

->
aa bb cTT #dd
```

### Option

#### --row-num|-r

target row (default: all)

- Ex1 single row

```sh.sh
echo ~" | aku rep -r "21"
```

- Ex2 multiple row

```sh.sh
echo "~" | aku rep -r "1" -r "3-4"
```

- Ex3 multiple row by end range

```sh.sh
echo "~" | aku rep -r "1" -r "-4"
```

#### --delimitter|-d

delimitter (default is space)

- Ex string delimitter

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku rep -f "2:bb" -d *AA"

->
aaAAAbbAAAccAAA#dd
```

#### --output-delimiter|-o

output delimiter (deafult is delimiter)

- Ex

```sh.sh
echo "aa  bb     cc      #dd" | aku rep -o "	"

->
bb cc
```

#### --turn|-t

gnu awk gensub third parameter

- Ex

```sh.sh
echo "aa bb cc #dd" | aku rep -f "1:B" -t "1"

->
Ba bb cc #dd
```

## Hld

Extract row between start holder and end holder

### [ARG]
Arg or stdin

### [Option]

#### --start-holder|-s

start holder

#### --end-holder|-e

end holder

- [Ex1] one pair

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e "^dd$"

->
aa
bb
cc
dd
```

- [Ex2] mutiple holder

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e "^dd$"  -s "^ee$" -e "^ff$"

->
aa
bb
cc
dd
ee
ff
```

- [Ex3] duplication holder

```sh.sh
echo "aa
bb
cc
dd
ee
fff" | aku hld -s "^aa$" -e "^dd$"  -s "^bb$" -e "^ee$"

->
"aa
bb
cc
dd
ee
```

#### --negative|-n

negative match


- [Ex1] one pair

```sh.sh
  
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e/x22/^cc$x22 -n

->
dd
ee
ff
```

- [Ex2] mutiple holder

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e "^cc$"  -s "^dd$" -e "^ee$" -n

->
ff
```

- [Ex3] duplication holder

```sh.sh
echo "aa
bb
cc
dd
ee
fff" | aku hld -s "^aa$" -e "^dd$"  "^bb$" -e "^ee$" -n

->
ff
```

#### --holder-layout|-l

output specify format
value: 
- start: only start hodler
- end: only end holder no bound str
- left: output line with start holder prefix by tab separated
- blank: normal
  
##### this option cannot specify sametime with negative option


- [Ex] start

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e/x22/^cc$x22 -l start

->
aa
bb
```

- [Ex] end

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e/x22/^cc$x22 -l end

->
bb
cc
```

- [Ex] out

  ```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e/x22/^cc$x22 -l out

->
bb
```

- [Ex] left

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e/x22/^cc$x22 -l left

->
aa	bb
aa	cc
```

#### --boudary-str|-b

put string after end holder 

##### this option enable in blank and end layout: becuase of require end holder

- [Ex]

```sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku hld -s "^aa$" -e/x22/^cc$x22 -b "
"

->
aa
bb
cc
```

## Trm

trim space and tab from line

### Arg

- [Ex] trim char
default is space / tab / zenkaku space

- [Ex] default trim char

```sh.sh
echo " aa 	" | aku trim

->
aa
```

-  [Ex] specify char

```sh.sh
aku trim "cb " -i "cc aa bb cc"

->
aa
```

- [Ex] specify char by consec

```sh.sh
echo "cc aa bb cc" | aku trim "c " " " "b "

->
aa
```

### Option

#### --delete-prefix|-p

delete prefix line


- [Ex]

```sh.sh
echo -e "aa
bb
//cc
#dd" | aku trim -p "#" -p "//"

->
aa
bb"
```

#### --delete-contain|-c
		delete contain line
- [Ex]

```sh.sh
aku trim -i "aa
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
echo -e "aa
bbdd
//cc
#dd" | aku trim -s "dd" -s "cc"

->
aa
```

#### --delete-regex|-p

tdelete regex line

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
aku trim -i "aa
cbb
//ccbb
#caabb" -p "c" -s "bb" -a

->
aa
```

- [Ex2] contain "and"

```sh.sh
aku trim -i "aa
cbb
//ccabsedsbb
#caaabsedsbb" -c "abs" -c "ads" -a

->
aa
```

- [Ex2] contain and regex "and"

```sh.sh
aku trim -i "aa
cbb
//ccabsedsbb
#caaabsedsbb" -r ".*abs.*" -c "ads" -a

->
aa
```

## Up

to lowercase


### Arg

- Ex

aku up "aa"
->
AA

### Option


#### --position|-p

specify position

- Ex

```sh.sh
aku up "aaaa" -p 1
->
Aaaa
```

- Ex

```sh.sh
aku up "aaaa" -p 2-4
->
aAAA
```

- Ex

```sh.sh
aku up "aaaa" -p 1
->
Aaaa
```

- Ex

```sh.sh
aku up "aaaa" -p 2-4
->
aAAA
```

- Ex

```sh.sh

aku up "aaaa" -p -3
->
AAAa

```

#### --lower|-l

- Ex

```sh.sh
aku up "AAAA" -l -3
->
aaaA
```
## Apl

Apply cmd to field or row in pipe

### ARG

Arg

#### first arg

proc cmd

- default first cmd: echo "${0}"

- @{0}, @{1}, @{2}.. to $0, $1, $2..  in awk

#### --if|i

apl condition regex

- Ex confition for stdout

```.sh.sh
echo "aa
bb" | aku apl -i "aa" "sed 's/^/PREFIX/'"

->
PREFIXaa
bb
```

- Ex confition for proc

```.sh.sh
```

#### --field-num|-f

target field

- Ex single field (default: all)

```sh.sh
echo "aa"    bb   cc    #dd" | aku apl "echo @[1}" -f "2"
```

- Ex multiple field

```sh.sh
echo "aa"    bb   cc    #dd" | aku apl "echo @[1}" -f "1" -f "3-4"
```

- Ex multiple field by end range

```sh.sh
echo "aa"    bb   cc    #dd" | aku apl "echo @[1}" "1" -f "-4"
```

- Ex multiple field by end range

```sh.sh
echo "aa"    bb   cc    #dd" | aku apl "echo @[1}" -f "1" -f "2-"
```

#### --row-num|-r

target row (default: all)

- Ex single row

```sh.sh
echo ~" | aku apl "echo @[1}" -r "2"
```

- Ex multiple row

```sh.sh
echo "~" | aku apl "echo @[1}" -r "1" -r "3-4"
```

- Ex multiple row by end range

```sh.sh
echo "~" | aku apl "echo @[1}" -r "1" -r "-4"
```

- Ex range specify -end

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku apl "echo @[1}" "[a-z]" -r -2
->
A
B
ccC
Ddd
```

- Ex range specify -start 

```.sh.sh
echo "aaA
bwBb
ccC
Ddd" | aku apl "echo @[1}" "[a-z]x22 -r 2-
->
aaA
B
C
D
```

- Ex range specify start-end 

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku apl "echo @[1}" "[a-z]" -r 2-4
->
aaA
B
C
D
```

- Ex multiple 

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku apl "echo @[1}" "[a-z]" -r 1 -r 3-4
->
A
bBb
cC
D
```

#### --on-negative|-n

negative to field num and row num

- Ex

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku apl "echo @[1}" -n -f "2" -d *AA"
```



## Tr

Total replace

### ARG

Arg

#### first arg

regex (default : newline)

#### second arg (default : blank)

replace str

- Ex remove newline

```.sh.sh
echo "aa
bb" | aku tr

->
aabb
```

- Ex replace string

```.sh.sh
echo "aa
bb" | aku tr "(a)
b" "\\1NEWLINE"

->
aNEWLINEb
```

### Option

#### --input-i

recieve input
```

- Ex

```.sh.sh
aku tr "aa" -i "aabb"
->
bb
```

#### --turn|-t

- Ex

```.sh.sh
echo "aa
bb" | aku tr "(a)
b" "\\1NEWLINE" -t 
->
aNEWLINEb
```

- Ex range specify -end

```.sh.sh
echo "aa
bb
cc
dd" | aku tr -t -2
->
aabbcc
dd
```

- Ex range specify -start 

```.sh.sh
echo "aa
bb
cc
dd" | aku tr -t 2-
->
aa
bbccdd
```

- Ex range specify start-end 

```.sh.sh
echo "aa
bb
cc
dd" | aku tr -t 2-4
->
aa
bbccdd
```

- Ex multiple 

```.sh.sh
echo "aa
bb
cc
dd
ee
ff" | aku tr -t 1-2 -t 4-5
->
aabbcc
ddeeff
```

## Uni

Union variables

### ARG

Arg

- Ex two arg

```sh.sh
aku uni "aa" "bb"
->
aa
bb
```

- Ex multiple arg

```sh.sh
aku uni "aa" "bb" "cc"...
->
aa
bb
cc
...
```

### Option

#### --bound-str|-b

union by bound str (default: newline)

- Ex

```sh.sh
aku uni "aa" "bb" -b "\n---"
->
aa
---bb
```


## Fld

Fold each field

### ARG

Arg or stdin

### Option

#### --insert-header-cycle|-i

insert header cycle (default: 5)

- Ex

```sh.sh
echo ~ | aku fld -i 3
```

#### --fold-col-cycle|-c

fold col cycle (default: 5)

- Ex

```sh.sh
aku fld -i 3 -c 3 | {file path}
```

#### --header-row-num|-l

specify header low num (default: 5)

- Ex

```sh.sh
echo ~ | aku fld -i 3 -c 3
```

#### --insert-header-cycle|-i

insert header cycle (default: 5)

- Ex

```sh.sh
echo ~ | aku fld -i 3
```

#### --delimiter|-d

field delimiter

- Ex

```sh.sh
echo ~ | aku fld -i 3 -d '\t'
```

#### --prefix|-p

header prefix string

- enable with header

- Ex

```sh.sh
aku fld -p "###" {file path}
```

#### --suffix|-s

header suffix string

- Ex

```sh.sh
aku fld -s "###" {file path}
```

## Sd

Replace by line

### ARG

Arg

#### first arg

regex (default : blank)

#### second arg (default : blank)

replace str

- Ex remove str

```.sh.sh
echo "aa
bb" | aku sd "aa"

->

bb
```

- Ex replace string

```.sh.sh
echo "aa
bb" | aku sd "(a)" "PREFIX\\1SUFFIX"

->
PREFIXaSUFFIXPREFIXaSUFFIX
b
```

### Option

#### --input-i

recieve input
```

- Ex

```.sh.sh
aku sd "aa" -i "aa
bb"
->

bb
```

#### --turn|-t

- Ex

```.sh.sh
echo "aa
bb" | aku sd "(a)
b" "\\1SUFFIX" -t 1
->
aaSUFFIX
bb
```

- Ex range specify -end

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku sd "[a-z]" -r -2
->
A
B
ccC
Ddd
```

- Ex range specify -start 

```.sh.sh
echo "aaA
bwBb
ccC
Ddd" | aku sd "[a-z]x22 -r 2-
->
aaA
B
C
D
```

- Ex range specify start-end 

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku sd "[a-z]" -r 2-4
->
aaA
B
C
D
```

- Ex multiple 

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku sd "[a-z]" -r 1 -r 3-4
->
A
bBb
cC
D
```

## Iro

Coloring by hex string

### ARG

Arg

#### first arg

property (default color:green,bold)

##### key

- color: text color

pre reserved color string: `black`, `white`
bellow exist d- / l- type
`green`, `azure`, `blue`, `red`, `brown`, `yellow`

- back: background color

- under: under line

- bold: bold text

- Ex default color: green

echo "aa
bb" | aku iro

- Ex blue text & light red background & bold & under line

```sh.sh
echo "aa
bb" | aku iro color:blue,back:lred,bold,under
```

- Ex hex color stirng

```sh.sh
echo "aa
bb" | aku iro "color:#2f41ba"
```

- Ex enable hex num specify

```sh.sh
echo "aa
bb" | aku iro color:2f41ba
```

- Ex blue text & light red background & bold & under line

```sh.sh
echo "aa
bb" | aku iro color:blue,back:lred,bold,under
```

- Ex short syntax

```sh.sh
echo "aa
bb" | aku iro dgreen
```

#### second arg (default : blank)

target str saround by ()

- Ex 

```sh.sh
echo "aa
bb" | aku iro '(aa)bb'

->

bb
```

### Option

#### --field-num|-f

target field

- Ex single field (default: all)

```sh.sh
echo "aa    bb   cc    #dd" | aku iro "color:green" -f "2"
```

- Ex multiple field

```sh.sh
echo "aa    bb   cc    #dd" | aku iro -f "1" -f "3-4"
```

- Ex multiple field by end range

```sh.sh
echo "aa    bb   cc    #dd" | aku iro -f "1" -f "-4"
```

- Ex multiple field by end range

```sh.sh
echo "aa    bb   cc    #dd" | aku iro -f "1" -f "2-"
```

#### --row-num|-r

target row (default: all)

- Ex single row

```sh.sh
echo ~" | aku iro -r "2" | aku
```

- Ex multiple row

```sh.sh
echo "~" | aku iro -r "1" -r "3-4"
```

- Ex multiple row by end range

```sh.sh
echo "~" | aku iro -r "1" -r "-4"
```

- Ex range specify -end

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku iro "[a-z]" -r -2
->
A
B
ccC
Ddd
```

- Ex range specify -start 

```.sh.sh
echo "aaA
bwBb
ccC
Ddd" | aku iro "[a-z]x22 -r 2-
->
aaA
B
C
D
```

- Ex range specify start-end 

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku iro "[a-z]" -r 2-4
->
aaA
B
C
D
```

- Ex multiple 

```.sh.sh
echo "aaA
bBb
ccC
Ddd" | aku iro "[a-z]" -r 1 -r 3-4
->
A
bBb
cC
D
```

#### --delimitter|-d

delimitter (default is space)

- Ex string delimitter

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku iro red -f "2" -d *AA"
```
```

- Ex consec space delimiter

```sh.sh
echo "aa  bb     cc      #dd" | aku iro "color:#847334" -f "2" -d " "
```

#### --on-negative|-n

negative to field num and row num

- Ex

```sh.sh
echo "aaAAAbbAAAccAAA#dd" | aku iro -n -f "2" -d *AA"
```

#### --input-i

recieve input
```

- Ex

```sh.sh
aku iro "aa" -i "aa
bb"
->

bb
```

#### --turn|-t

- Ex

```.sh.sh
echo "aa
bb" | aku iro "(a)
b" "\\1SUFFIX" -t 1
->
aaSUFFIX
bb
```

