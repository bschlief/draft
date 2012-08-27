#!/usr/bin/env ruby

require 'curses'
include Curses

############################################
# displays the entries which contain
# all the search terms in the search string
# up to the number of rows provided by
# the terminal
def disp(search_str, col_headers, entries, selection_idx)
  rows = lines

  # adjustments for search string,
  # 0 based index, column headers
  rows -= 4

  # mask the entries by the strings containing
  # all the sarch terms
  search_str_arr = search_str.split(/\s/)
  selected = entries.select do |s| 
    contains_terms = search_str_arr.collect { |str| s.include? str }
    contains_terms.all? 
  end

  addstr "Search? #{search_str}  (#{selected.length} Entries Selected) [Selected = #{selection_idx}]\n"

  if selection_idx > selected.length then
    selection_idx = selected.length  
  end

  # print the column headers, and the 
  # selected items.  fill remainder of
  # terminal with whitespace. 
  addstr "#{col_headers}\n"
  selected[0..rows].each_with_index do |str,idx|
    if (idx == selection_idx)
      attrset(A_BOLD)
      attrset(A_REVERSE)
    end
    addstr "#{str}\n" 
    if (idx == selection_idx)
      attrset(A_NORMAL)
    end
  end

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
  init_screen
  raw
  stdscr.keypad(true)
  noecho
  curs_set 2
  ch = 0
  name = "none"

  filename = "adp_csv.csv"
  entries = read_file(filename)
  col_headers = entries.shift

  search_str = ""
  selection_idx = 0

  KEY_ESCAPE = 27

  ROW_MAX = lines
  ROW_MIN = 0

  while ch != KEY_CTRL_Q
    clear

    if ch.class == String then
      search_str << ch
      selection_idx = 0 
   end
     
    if (ch == KEY_ESCAPE) then
      search_str = "" 
      selection_idx = 0   
    end 

    if (ch == KEY_DC || ch == KEY_DL || ch == KEY_BACKSPACE) then
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

#    addstr "Ch is #{ch.class} #{ch.to_i} #{keyname(ch)} SEARCH: #{search_str}\n"
    disp(search_str, col_headers, entries, selection_idx)
    refresh
    ch = getch

  end
ensure
  close_screen 
end

