#!/usr/bin/ruby
require "rubygems"
require "highline/system_extensions"
include HighLine::SystemExtensions

filename = "adp_csv.csv"

############################################
# displays the entries which contain
# all the search terms in the search string
# up to the number of rows provided by
# the terminal
def disp(search_str, col_headers, entries)
  cols, rows = terminal_size
  
  # adjustments for search string,
  # 0 based index, column headers
  rows -= 4

  printf "Search? %s \n", search_str

  # mask the entries by the strings containing
  # all the sarch terms
  search_str_arr = search_str.split(/\s/)
  selected = entries.select do |s| 
    contains_terms = search_str_arr.collect { |str| s.include? str }
    contains_terms.all? 
  end

  # print the column headers, and the 
  # selected items.  fill remainder of
  # terminal with whitespace. 
  puts col_headers
  puts selected[0..rows]

  # fill blank lines to push search menu to top
  (selected.length..rows).each { puts "" }
end


# read the file
lines = []
widths = [0,0,0,0,0,0,0]

File.open(filename, "rb").each_line do |line|
  line_arr = line.chomp.split(/,/)
 
  line_arr_lens = line_arr.map { |item| item.length }

  line_arr_lens.each_index do |i|
    widths[i] = line_arr_lens[i] if line_arr_lens[i] > widths[i]
  end

  lines << line_arr
end

entries = lines.map do |item| 
  str = ""
  col_whitespace = 2
  item.each_index { |i| str << item[i].ljust(widths[i]+col_whitespace) }
  str
end

# throw away first 4 lines, contains no useful stuff
entries.shift(4)

col_headers = entries.shift

search_str = ""
disp(search_str, col_headers, entries)

loop do
  char = get_character

  if char == 127 then # 127 is the 'Delete character'
    search_str.chop!
  elsif char == 27  # 27 is the 'Escape' character
    search_str = ""
  else
    search_str << char
  end

  disp(search_str, col_headers, entries)

end


