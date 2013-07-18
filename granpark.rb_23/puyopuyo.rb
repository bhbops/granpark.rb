#!/usr/bin/ruby

# コマンドライン引数からデータファイル名を取得
$datafile = ARGV[0]
if $datafile == nil then # 無指定時のデータファイル名
	$datafile = "puyo.data"
end

# グローバル変数
$stack = [] # 探索結果を一時的にためる

# 読み込んだデータを一問づつ解析
def analysis_data(row, col, data)
	counter = 2
	offset = 0
	while (offset = search_origin(data)) != -1 do
		if trace(offset, row, col, data) == 0 then
			break
		end
		$stack.each { |c|
			data[c] = counter  # 0で埋めてもかまわない
		}
		$stack.clear
		counter += 1
	end
	return counter - 2
end

# データ中の左上の1を探す
def search_origin(data)
	found = 0
	offset = 0
	data.each { |item|
		if item == "1" then
			found = 1
			break
		end
		offset += 1
	}
	return (found == 1) ? offset : -1
end

# 連接した１を探索する
def trace(offset, row, col, data)
	result = add_stack(offset) ? 1 : 0

	result += move_right(offset, row, col, data)
	result += move_down(offset, row, col, data)
	result += move_left(offset, row, col, data)
	result += move_up(offset, row, col, data)
	return result
end

# ひとつ右を調べる
def move_right(offset, row, col, data)
	if offset % row == row - 1 then
		return 0 # 右端
	end
	offset += 1
	if data[offset] == "1" then
		if add_stack(offset) then
			trace(offset, row, col, data)
			return 1
		end
	end
	return 0
end
	
# ひとつ下を調べる
def move_down(offset, row, col, data)
	if offset + col > row * col then
		return 0 # 最下行
	end
	offset += col
	if data[offset] == "1" then
		if add_stack(offset) then
			trace(offset, row, col, data)
			return 1
		end
	end
	return 0
end
	
# ひとつ左を調べる
def move_left(offset, row, col, data)
	if offset % row == 0 then
		return 0 # 左端
	end
	offset -= 1
	if data[offset] == "1" then
		if add_stack(offset) then
			trace(offset, row, col, data)
			return 1
		end
	end
	return 0
end
	
# ひとつ上を調べる
def move_up(offset, row, col, data)
	if offset < col then
		return 0 # 一行め
	end
	offset -= col
	if data[offset] == "1" then
		if add_stack(offset) then
			trace(offset, row, col, data)
			return 1
		end
	end
	return 0
end

# 見つかった１の場所(offset)をスタックに積む。二重登録しないようにする
def add_stack(offset)
	if $stack.index(offset) == nil then
		$stack.push(offset)
	end
end

# メイン
def main()
	fields = 0
	row = col = row_count = 0
	data = []

	# データファイル読込み
	open($datafile) {|file|
		while l = file.gets
			fields = l.split(' ')
			if row == 0 && col == 0 then
				# 行数と列数を取得
				row = fields.fetch(0).to_i
				col = fields.fetch(1).to_i
				row_count = 0
			else
				row_count += 1
				data.concat(fields)
				# 行数分だけデータを読み込む
				if (row_count >= row) then
					# 問題読み込み完了、解析
					puts analysis_data(row, col, data)
					row = col = row_count = 0 # カウンタリセット
					data.clear
				end
			end
		end
	}
end

main
