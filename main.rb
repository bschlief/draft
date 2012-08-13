#!/usr/bin/env ruby

require 'ffi-ncurses'
include FFI::NCurses

############################################
# displays the entries which contain
# all the search terms in the search string
# up to the number of rows provided by
# the terminal
def disp(search_str, col_headers, entries, selection_idx)
  rows = 210

  # adjustments for search string,
  # 0 based index, column headers
  rows -= 6

  # mask the entries by the strings containing
  # all the sarch terms
  search_str_arr = search_str.split(/\s/)
  selected = entries.select do |s| 
    contains_terms = search_str_arr.collect { |str| s.include? str }
    contains_terms.all? 
  end

  addstr "Search? #{search_str}  (#{selected.length} Entries Selected) [Selected = #{selection_idx}]\n"

  # print the column headers, and the 
  # selected items.  fill remainder of
  # terminal with whitespace. 
  addstr col_headers + "\n"
  selected[0..rows].each { |s| addstr s + "\n" }

end

def read_file(filename)
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
  entries
end

begin
  initscr
  raw
  keypad stdscr, true
  noecho
  curs_set 0
  ch = 0
  name = "none"

  filename = "adp_csv.csv"
  entries = read_file(filename)

  col_headers = entries.shift

  search_str = ""
  selection_idx = 0

  KEY_DELETE = 127
  KEY_ESCAPE = 27

  ROW_MAX = 210
  ROW_MIN = 0

  while ch != KEY_CTRL_Q
    clear
#    addstr sprintf("name: %s dec: %d char: [%s]\n", name, ch, (1..127).include?(ch) ? ch.chr : " ")

    if ((32..122).include?(ch)) then
      search_str << ch
      selection_idx = 0 
    end

    if (ch == KEY_ESCAPE) then
      search_str = "" 
      selection_idx = 0   
    end 

    if (ch == KEY_DELETE || ch == KEY_BACKSPACE) then
      search_str.chop! 
      selection_idx = 0
    end
    
    if (ch == KEY_DOWN || ch == KEY_RIGHT) then
      selection_idx += 1
      selection_idx = ROW_MAX if selection_idx > ROW_MAX
    end

    if (ch == KEY_UP || ch == KEY_LEFT) then
      selection_idx -= 1
      selection_idx = ROW_MIN if selection_idx < ROW_MIN
    end

    disp(search_str, col_headers, entries, selection_idx)
    refresh
    ch = getch
    name = keyname(ch)
  end
ensure
  endwin
end

