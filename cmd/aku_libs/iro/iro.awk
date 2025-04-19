
function to_ansi_color2(hex_color, text_or_back){
  # "#4caf50"  # 色を指定
 

    hex = substr(hex_color, 2) # '#'を削除
    r = strtonum("0x" substr(hex, 1, 2))
    g = strtonum("0x" substr(hex, 3, 2))
    b = strtonum("0x" substr(hex, 5, 2))
  # 16進数カラーコードをrgbに変換
  # hex_to_rgb(hex_color, r, g, b)

  # ansiエスケープコードを生成して表示
  return sprintf(\
	   "\033[%d;2;%d;%d;%dm", \
	  	text_or_back, r, g, b\
  	)
}

function to_ansi_color(hex) {
  # HEXカラーをRGBに変換
  r = strtonum("0x" substr(hex, 1, 2))
  g = strtonum("0x" substr(hex, 3, 2))
  b = strtonum("0x" substr(hex, 5, 2))

  # RGBからANSI 256色コードを計算 (近似値)
  #  https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
  color_code = 16 + (r * 36 / 256) + (g * 6 / 256) + (b / 256)
  return color_code
}

function make_ansi_replace_string(\
	text_hex_color, \
	back_hex_color, \
	bold, \
	under_line\
){
  # "#4caf50"  # 色を指定
  # text = "colored text" # 表示するテキスト
  # 16進数カラーコードをrgbに変換する関数
 	bold_ansi = ""
  	if(bold != ""){
  		bold_ansi = "\033[1m"
  	}
  	under_line_ansi = ""
  	if(under_line != ""){
  		under_line_ansi = "\033[4m"
	}	
	text_color_ansi = ""
	if(text_hex_color != ""){
	  	text_color_ansi = to_ansi_color2(text_hex_color, 38) 
	}
	bg_color_ansi = ""
	if(back_hex_color != ""){
	  	bg_color_ansi = to_ansi_color2(back_hex_color, 48) 
	}
  # ansiエスケープ 
	return  sprintf(\
  		"%s%s%s%s", \
  		bold_ansi, under_line_ansi,\
  		text_color_ansi, bg_color_ansi\
	)
}

# 関数名: is_hex_color
# 機能: 文字列が16進数カラーコード（#RRGGBBまたは#RGB形式）かどうかを判定する
# 引数:
#   str: 判定する文字列
# 戻り値:
#   1 (真): 16進数カラーコードである
#   0 (偽): 16進数カラーコードではない
function is_hex_color(str) {
  # 長さが7 (#RRGGBB) または 4 (#RGB) で、
  # 先頭が '#' で、
  # 残りの文字が16進数文字 (0-9, a-f, A-F) であるかチェックする
  if (length(str) == 7 || length(str) == 4) {
    if (substr(str, 1, 1) == "#") {
      hex_chars = "0123456789abcdefABCDEF"
      for (i = 2; i <= length(str); i++) {
        char = substr(str, i, 1)
        if (index(hex_chars, char) == 0) {
          return 0  # 16進数文字ではない
        }
      }
      return 1  # すべての文字が16進数文字
    }
  }
  return 0  # 条件に合わない
}

function make_text_by_color(\
	text,
	regex_con,
	turn,
	property_map,\
	color_key,\
	back_key,\
	bold_key,\
	under_line_key\
){
	ansi_prefix_str = make_ansi_replace_string(\
		property_map[color_key],\
		property_map[back_key],\
		property_map[bold_key],\
		property_map[under_line_key]\
	)
	replace_str = ansi_prefix_str"\\1\033[0m"
	# print "replace_str "replace_str
	regex_con = sprintf("%s", regex_con)
	return gensub(regex_con, replace_str, turn, text)
}
