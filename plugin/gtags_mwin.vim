" Author: Kalimuthu Velappan
" Version: 1.2
" Last Modified: June 04, 2012
" Email: kalmuthu@gmail.com
" Desription: Gtag support for multiwindow

" Copyright and licence
" ---------------------
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
" 
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
" 
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" Overview
" --------
" The gtags.vim plug-in script integrates the GNU GLOBAL source code tag system
" with Vim. About the details, see http://www.gnu.org/software/global/.
"
" Installation
" ------------
" Drop the file in your plug-in directory or source it from your vimrc.
" To use this script, you need the GNU GLOBAL-5.7 or later installed
" in your machine.

" Usage
" -----
" 
" 1. To go to symbol(variable/function) definition, place cursor cursor under the symbol
"    and press Ctl + \, you would get the similar to following:
"     
"     ============= TAG : [FILE_NAME_LENGTH] ================
"     main/system/header.h  70  #define FILE_NAME_LENGTH  32    
"     main/control/views.h  17  #define FILE_NAME_LENGTH  24 
"     main/program/forms.h  23  #define FILE_NAME_LENGTH  12    
"	  ... 
"     Cursor is place under the list, Press <ENTER> key to select/navigate the tag
" 
" 2. To go to reference of the symbol(variable/function) definition, place cursor cursor 
"     under the symbol and press Ctl + R, you would get the similar to following:
"     
"     ============= TAG : [FILE_NAME_LENGTH] ================
"     main/system/header.c  70  int len = FILE_NAME_LENGTH;
"     main/control/views.c  17  size = FILE_NAME_LENGTH+1;
"     main/program/forms.c  23  int max = FILE_NAME_LENGTH + 12;
"     ...
"     Cursor is place under the list, Press <ENTER> key to select/navigate the tag
" 
" 3. To come back to previous tag/window, press Ctl + D.
" 
" 4. Similarly, to get the variable symbol definition, place cursor cursor under the symbol
"    and press Ctl + S.
"     
" 5. To browse the Tag Stack, press Ctl + T key, you would get similar to the following.
" 
"    ============================== TAG : [StackTag]========================
"    main/system/process.c         | 5         | FILE_NAME_LENGTH    | FILE
"	 1_1_FILE_NAME_LENGTH_1        | 2         | FILE_NAME_LENGTH    | TAG
"	 main/system/header.c          | 95        | FILE_NAME_LENGTH    | FILE
" 
" 
" If you dont want the multiwindow support, You can use the suggested key mapping with the following code:
"
"	[$HOME/.vimrc]
"	let No_Gtags_Multi_Window_Auto_Map = 1
"

"finish
if exists("loaded_gtags_multi_window")
    finish
endif


if !exists("g:Gtags_Result_Format")
    "let g:Gtags_Result_Format = "ctags-mod"
    let g:Gtags_Result_Format = "ctags-mod"
endif

" Character to use to quote patterns and file names before passing to global.
" (This code was drived from 'grep.vim'.)
if !exists("g:Gtags_Shell_Quote_Char")
    if has("win32") || has("win16") || has("win95")
        let g:Gtags_Shell_Quote_Char = '"'
    else
        let g:Gtags_Shell_Quote_Char = "'"
    endif
endif
if !exists("g:Gtags_Single_Quote_Char")
    if has("win32") || has("win16") || has("win95")
        let g:Gtags_Single_Quote_Char = "'"
        let g:Gtags_Double_Quote_Char = '\"'
    else
        let s:sq = "'"
        let s:dq = '"'
        let g:Gtags_Single_Quote_Char = s:sq . s:dq . s:sq . s:dq . s:sq
        let g:Gtags_Double_Quote_Char = '"'
    endif
endif

if !exists("g:Gtags_Auto_Update_Tags")
    let g:Gtags_Auto_Update_Tags = 0
endif
"
" Display error message.
"
function! s:Error(msg)
    echohl WarningMsg |
           \ echomsg 'Error: ' . a:msg |
           \ echohl None
endfunction
"
" Trim options to avoid errors.
"
function! s:TrimOption(option)
    let l:option = ''
    let l:length = strlen(a:option)
    let l:i = 0

    while l:i < l:length
        let l:c = a:option[l:i]
        if l:c !~ '[cenpquv]'
            let l:option = l:option . l:c
        endif
        let l:i = l:i + 1
    endwhile
    return l:option
endfunction

"
" Execute global and load the result into quickfix window.
"
function! s:ExecLoad(option, long_option, pattern, title, file)
    " Execute global(1) command and write the result to a temporary file.
    let l:isfile = 0
    let l:option = ''
    let l:result = ''

    if a:option =~ 'f'
        let l:isfile = 1
        if filereadable(a:pattern) == 0
            call s:Error('File ' . a:pattern . ' not found.')
            return 0
        endif
    endif
    if a:long_option != ''
        let l:option = a:long_option . ' '
    endif
    "let l:option = l:option . '--result=' . g:Gtags_Result_Format
    "let l:option = l:option . ' -q'. s:TrimOption(a:option)
    let l:option = l:option . ' -q'. a:option . ' '
    if l:isfile == 1
        let l:cmd = 'global ' . l:option . ' ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char
    else
        let l:cmd = 'global ' . l:option . ' -e ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char 
    endif

	let l:cmd = l:cmd . " ". a:file
    "echoerr "CMD = ".l:cmd

    "let l:cmd = substitute(l:cmd, '['']', '\\&', "g")
	"let l:cmd = escape(l:cmd, '''')
	"let curpath = getcwd()
	"if a:file != ' '
		":cd %:h
	"endif
	
    let l:result = system(l:cmd)

	"if a:file != ' '
		"execute "cd  ". curpath
	"endif

    if v:shell_error != 0
        if v:shell_error != 0
            if v:shell_error == 2
                call s:Error('invalid arguments. (gtags.vim requires GLOBAL 5.7 or later)')
            elseif v:shell_error == 3
                call s:Error('GTAGS not found.')
            else
                call s:Error('global command failed. command line: ' . l:cmd)
            endif
        endif
        return 0
    endif
    if l:result == '' 

		"echoerr "[".a:long_option."]"
		if a:long_option =~ 'next'
			return 1
		elseif a:long_option == ''
			call s:ExecLoad(a:option, ' -c '.a:long_option, a:pattern, a:title, ' ') 
		elseif l:option =~ 'f'
            call s:Error('Tag not found in ' . a:pattern . '.')
        elseif l:option =~ 'P'
            call s:Error('Path which matches to ' . a:pattern . ' not found.')
        elseif l:option =~ 'g'
            call s:Error('Line which matches to ' . a:pattern . ' not found.')
        else
            call s:Error('Tag which matches to ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char . ' not found.')
        endif
        return 0
    endif

	"echo "before: " . a:pattern
	let tag_name =substitute(a:title, '[\[\]\-*\^\. ]',"_", "g")
	"echoerr pattern_tag
	let l:progress=""
	if filereadable("GFILE")
		try
			let l:progress = join(readfile("GFILE"),"")
		catch
		endtry
	endif

	if l:progress != "" 
		let l:progress = l:progress . "              | 000 | Update in progres.......... | please retry little later ........"."\n"
		let l:result = l:progress . l:result
		"syntax match GtagsOutputFunction l:progress
	endif

    call OpenTag(tag_name, a:pattern, l:result)
	return 0

endfunction


function MaxLine()
	let maxcol = 0
	let lnum = 2
	while lnum <= line("$")
		let words = split(getline(lnum), '\t')
		if strlen(words[0]) > maxcol
			let maxcol = strlen(words[0])
		endif
		let lnum += 1
	endwhile
	"echo "Line has" maxcol - 1 "characters"
	return maxcol
endfunction

function AlignColoumn()
	let maxcol = MaxLine()
	let lnum = 2
	"set modifiable
	if maxcol > 40
		let maxcol=40
	endif
	while lnum <= line("$")
		let words = split(getline(lnum), '\t')
		let fill = maxcol - strlen(words[0])
		"if fill > maxcol/2
			"let fill = maxcol
		"endif
		let	words[0] = words[0].repeat(' ', fill)
		let linestr = join(words, '	')
		call setline(lnum, linestr)
		let lnum += 1
	endwhile
	"set nomodifiable

endfunction


" ---------------------------- MULTIWINDOW   GTAG  ----------------------------------------

function! s:GtagsCursor_x()
    let l:pattern = expand("<cword>")
    call s:ExecLoad('dx --result=ctags-mod', ' ', l:pattern, l:pattern, ' ')
    "if s:ExecLoad('dx --result=ctags-mod', 'next', l:pattern, l:pattern, ' ') == 1
	    "call s:ExecLoad('s --result=ctags-mod', ' ', l:pattern, l:pattern, ' ') 
	"endif
endfunction


function! s:GtagsCursor_r()
    let l:pattern = expand("<cword>")
    "call s:ExecLoad('rx --result=ctags-mod', ' ', l:pattern, l:pattern, ' ')
    if s:ExecLoad('rx --result=ctags-mod', 'next', l:pattern, l:pattern, ' ')
		call s:ExecLoad('sx --result=ctags-mod', ' ', l:pattern, l:pattern, ' ')
	endif
endfunction



function! s:GtagsCursor_s()
    let l:pattern = expand("<cword>")
    call s:ExecLoad('s --result=ctags-mod', ' ', l:pattern, l:pattern, ' ')
endfunction


function! s:GtagsCursor_fg()
    let l:pattern = expand("<cword>")
	let l:input = input("FIND-PATTERN:", l:pattern )
	"let l:input = input("F-PATTERN:" )
	if(l:input == '') 
		return 
	endif
	let l:pattern = l:input
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
    call s:ExecLoad('gx --result=ctags-mod', '', l:pattern, "STRING_SEARCH", ' ')
endfunction


function! s:GtagsCursor_fgg()
    let l:pattern = expand("<cword>")
	let l:input = input("GREP-PATTERN:" )
	if(l:input == '') 
		return 
	endif
	let l:pattern = l:input
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
    call s:ExecLoad('gx --result=ctags-mod', '', l:pattern, "GREP_SEARCH", ' ')
endfunction


function! s:GtagsCursor_fdir_grep()
	let l:input = input("DIR-GREP-PATTERN:" )
	if(l:input == '') 
		return 
	endif
	let l:pattern = l:input
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
    call s:ExecLoad('gx --result=ctags-mod', '', l:pattern, "STRING_SEARCH", ' ')
endfunction


" shortcut Keys
" The key maps are assigned based on the easier and closer to the finger.
"	[$HOME/.vimrc]
"	let No_Gtags_Multi_Window_Auto_Map = 1
"
if !exists('gtags_open_definition')
    let gtags_open_definition = '<leader><C-\>'
endif
if !exists("gtags_open_definition_left_hand")
    let gtags_open_definition_left_hand = '<leader><C-LeftMouse>'
endif
if !exists("gtags_open_definition_ctags_stype")
    let gtags_open_definition_ctags_stype = '<leader><C-]>'
endif
if !exists("gtags_open_reference")
    let gtags_open_reference = '<leader><C-R>'
endif
if !exists("gtags_open_local_sym_reference")
    let gtags_open_local_sym_reference = '<leader><C-S>'
endif
if !exists("gtags_open_raw_string_search")
    let gtags_open_raw_string_search = '<leader><C-G>'
endif
if !exists("gtags_open_navigation_path")
    let gtags_open_navigation_path = '<leader><C-D>'
endif
if !exists("gtags_close_tag")
    let gtags_close_tag = '<leader><C-T>'
endif
if !exists('gtags_cmd_open_definition')
    let gtags_cmd_open_definition = '<leader><C-X><C-X>'
endif
if !exists('gtags_mouse_open_definition')
    let gtags_mouse_open_definition = '<leader><C-E>'
endif
if !exists('gtags_cmd_open_reference')
    let gtags_cmd_open_reference = '<leader><C-R><C-R>'
endif
if !exists('gtags_cmd_open_grep_search')
    let gtags_cmd_open_grep_search = '<leader><C-G><C-G>'
endif
if !exists('gtags_cmd_open_file_path')
    let gtags_cmd_open_file_path = '<leader><C-P><C-P>'
endif
if !exists('gtags_cmd_sub_string_search')
    let gtags_cmd_sub_string_search = '<leader><C-S><C-S>'
endif
if !exists('gtags_cmd_search_and_replace')
    let gtags_cmd_search_and_replace = '<leader><C-F><C-R>'
endif
if !exists('gtags_cmd_view_cursor_file')
    let gtags_cmd_view_cursor_file= '<leader><C-F><C-L>'
endif

if !exists("No_Gtags_Multi_Window_Auto_Map")
    let No_Gtags_Multi_Window_Auto_Map = 0
endif

if g:No_Gtags_Multi_Window_Auto_Map == 0
	exec "noremap ". g:gtags_open_definition ."   :call <SID>GtagsCursor_x()<CR>"
	exec "noremap ". g:gtags_mouse_open_definition ."   :call <SID>GtagsCursor_x()<CR>"
	exec "noremap ". g:gtags_open_definition_left_hand . " :call <SID>GtagsCursor_x()<CR>"
	exec "noremap ". g:gtags_open_definition_ctags_stype . " :call <SID>GtagsCursor_x()<CR>"
	exec "noremap ". g:gtags_open_reference . " :call <SID>GtagsCursor_r()<CR>"
	exec "noremap ". g:gtags_open_local_sym_reference . " :call <SID>GtagsCursor_s()<CR>"
	exec "noremap ". g:gtags_open_raw_string_search . " :call <SID>GtagsCursor_string_search()<CR>"
	exec "noremap ". g:gtags_open_navigation_path ." :call SelectWindowStackTag()<CR>"
	exec "noremap ". g:gtags_close_tag . " :call CloseTag() <CR>"
	exec "noremap <RightMouse> :call CloseTag() <CR>"

endif



let s:Tag={"TagName":"NULL", "TagPattern":"NULL", "TagFileName":"NULL","CurPos":0, "TagType":"NULL", "TagAutoClose":0}
let s:Stack=[]
let s:TagStack={"TagStack":0, "TagIndex":0, "CurrentTag":0}
let s:Window=[]
"silent highlight GtagsGroup ctermbg=LightGreen ctermfg=Black
"silent highlight GtagsGroup ctermbg=27 guifg=#005fff "rgb=0,95,255
"guifg=#660000
"silent highlight GtagsGroup  ctermbg=1



if !exists("loaded_gtags_multi_window")
    call add(s:Window, copy(s:TagStack))
endif
" Get the window number associated with it
function! GetWindowNumber()
    while len(s:Window) <= winnr("$")
        call AddWindow()
    endwhile
    return winnr()
endfunction

" Debug functions
function! DisplaySetup()
    call add(s:Stack, copy(s:Tag))
    let s:TagStack.TagStack=copy(s:Stack)
    call add(s:Window, copy(s:TagStack) )
    let s:Window[0].TagStack[0].TagName="TEST"
    echo  "Tag name=". s:Window[0].TagStack[0].TagName
endfunction

function! GetTagFileName(tag_name)
    let win_idx = GetWindowNumber()
    let tag_idx = s:Window[win_idx].TagIndex
    "return "~/.vim/tmp/". GetWindowNumber() ."_". winbufnr(0) ."_". a:tag_name."_".tag_idx
    return "". GetWindowNumber() ."_". winbufnr(0) ."_". a:tag_name."_".tag_idx
endfunction

" Open new Buffer
function! OpenBuffer(tag_name, file_name, tag_type)
    if !bufexists(a:file_name)
        execute("badd ". a:file_name)
    endif
endfunction 

" Open new Buffer
function! ViewBuffer(tag_name, file_name, tag_type)
	call OpenBuffer(a:tag_name, a:file_name, a:tag_type)
    execute("buffer ". a:file_name)
endfunction 

" Close the buffer
function! CloseBuffer(tag_name, file_name, tag_type)
    if bufexists(a:file_name)
        execute("bwipeout ". a:file_name)
		"if a:tag_type == "TAG" 
			"setlocal modifiable
            "call delete( a:file_name)
		"endif
    endif
endfunction 

function! SetTagColoring(tag_type)
    if a:tag_type == "TAG" 
		call matchadd("GtagsHeader", '\%1l')
		"call matchadd("GtagsOutputFile", '^[^| \t]\+')
		"call matchadd ("GtagsOutputLine", '|[0-9\t ]\+|')
		"call matchadd ("GtagsOutputFunction", ' [a-zA-Z_<>]\+[a-zA-Z_0-9<>]\+[ ]*|')
		"syntax match GtagsHeader '\%1l'
		syntax match GtagsOutputFile '^[^| \t]\+'
		syntax match GtagsOutputLine '|[0-9\t ]\+|'
		syntax match GtagsOutputFunction ' [a-zA-Z_<>]\+[a-zA-Z_0-9<>]\+[ ]*|'
		call matchadd ("GtagsProgressFile", "Update in progres..........")
	endif
endfunction

" Load the buffer for the given filename
function! LoadBuffer(tag_name, tag_pattern, file_name, line_no, tag_type, file_content)
    if !bufexists(a:file_name)
        call OpenBuffer(a:tag_name, a:file_name, a:tag_type)
    endif
    execute("buffer ". a:file_name)
    if a:tag_type == "TAG" 
		":cd %:h
        setlocal modifiable
        silent put=a:file_content
        let title = a:tag_name  
		let len = winwidth(0)- strlen(title)-2
		let title = repeat(" ", len/2).a:tag_name.repeat(" ", len/2)
        call setline(1, title)
		"call SelectMatch("GtagsHeader", '/\%1l/')
		"silent write
		"2,$!column -t -s '	' -o '	' 
		"call AlignColoumn()
        setlocal nomodifiable
        setlocal buftype=nowrite buflisted
        setlocal noswapfile
        setlocal cursorline 
        silent noremap <buffer> <Enter> :call SelectTag() <CR>
        silent noremap <buffer> <C-LeftMouse> :call SelectTag() <CR>
        "silent noremap <buffer> <2-LeftMouse> :call SelectTag() <CR>
        exec "silent noremap <buffer> " . g:gtags_open_definition 
        exec "silent noremap <buffer> " . g:gtags_mouse_open_definition 
	else
		call system("echo \"history -s \"v ".a:file_name. "\"\" >> ~/.vim/tmp/vfiles.txt")
    endif
    call cursor(a:line_no,1)
    call search(a:tag_name, '', line("."))
    call SetStackTopTag(a:tag_name, a:tag_pattern, a:file_name, a:tag_type, getpos("."))
    call SelectMatch("GtagsGroup", a:tag_pattern)
	call SetTagColoring(a:tag_type)
endfunction 

function! SelectMatch(group, tag_name)
    call clearmatches()
    if GetStackTopTagIndex() > 0 
		let match_str = a:tag_name
		let match_str = substitute(match_str, '\\[~!@#$%^&*()\-_=\+\[{\]}\|;:",\./\?]', '.', "g")
		"echoerr match_str
		let match_str = substitute(match_str, '[~!@#$%^&*()\-_=\+\[{\]}\|;:",\./\?]', '.', "g")
		"echoerr match_str
        call matchadd(a:group, match_str)
        "call matchadd(a:group, a:tag_name)
    endif
endfunction

" Select the buffer based on the Tag 
function! SelectBuffer(tag)
    if !bufexists(a:tag.TagFileName)
        call SetStackTopTag(a:tag.TagName, a:tag.TagPattern, a:tag.TagFileName, a:tag.TagType, getpos("."))
        return CloseTag()
    endif
    execute("buffer ". a:tag.TagFileName)
    call setpos(".", a:tag.CurPos)
    call SelectMatch("GtagsGroup", a:tag.TagPattern)
    call SetStackTopTag(a:tag.TagName, a:tag.TagPattern, a:tag.TagFileName, a:tag.TagType, getpos("."))
	call SetTagColoring(a:tag.TagType)
endfunction 

" Copy the Current tag details to Stack top
function! CopyCurrentToStackTop()

    let tag_type = GetStackTopTagType()
    if tag_type != "FILE" 
        return
    endif
    if GetStackTopTagIndex() <= 0 
        return
    endif
    let tag = GetStackTopTag()
    let current_pos = getpos(".")
    if line(".") == tag.CurPos[1] 
        return
    endif
    call PushCurrentTag(tag)
endfunction

" Open the new tag
function! OpenTag(tag_name, tag_pattern, content )
    call CopyCurrentToStackTop()
    call PushTag(a:tag_name, a:tag_pattern, bufname("%"))
    let tag_file_name = GetTagFileName(a:tag_name)
    call LoadBuffer(a:tag_name, a:tag_pattern, tag_file_name, 2, "TAG", a:content)
    call AutoSelectTag()
    
endfunction

" Close the tag 
function! CloseTag()
    let win_idx = GetWindowNumber()
    let tag_idx = s:Window[win_idx].TagIndex-1
    if tag_idx < 0 
        echohl WarningMsg | echo "Bottom of Stack" | echohl None
        return
    endif
    let ctag=GetStackTopTag()
    let tag=PopTag()
    call SelectBuffer(tag)
    if ctag.TagType == "TAG"
        call CloseBuffer( ctag.TagName, ctag.TagFileName, ctag.TagType)
    endif
    call AutoCloseTag()
endfunction 

" Automatically close the tag window when only one entry in the tag window
function! AutoCloseTag()

    let tag=GetStackTopTag()
    if tag.TagType != "TAG"
        return
    endif

    if line(".") <= 1
        return 
    endif
    if line("$") > 2
        return 
    endif
    call CloseTag()
endfunction 

" Select the Tag from Tag window
function! SelectTag()
    if line(".") <= 1
        return 
    endif
    let tag = GetStackTopTag()
    let words = split(getline("."), '[\t|:]')
	if len(words) < 2
		return 
	endif
    let file_name = substitute( words[0], " ", "", "g")
    let line_no = substitute(words[1], "[ |]", "", "g")
    call PushTag(tag.TagName, tag.TagPattern, bufname("%"))

    call LoadBuffer(tag.TagName, tag.TagPattern, file_name, line_no, "FILE", "")
	if g:Gtags_Auto_Update_Tags
		call UpdateGtags()
	endif


endfunction

" Automatically select the tag from tag window when there is only one entry
function! AutoSelectTag()


    let tag=GetStackTopTag()

    if line(".") <= 1
        return 
    endif
    if line("$") > 2
        return 
    endif
    call SelectTag()
endfunction

" Update the top stack contents
function! PushCurrentTag(ctag)
    let win_idx = GetWindowNumber()
    let tag_idx = s:Window[win_idx].TagIndex
    let tag = copy(s:Tag)
    let tag.TagName = a:ctag.TagName
    let tag.TagPattern = a:ctag.TagPattern
    let tag.TagFileName = a:ctag.TagFileName
    let tag.CurPos = copy(a:ctag.CurPos)
    let tag.TagType = a:ctag.TagType
    call add(s:Window[win_idx].TagStack, tag )
    let s:Window[win_idx].TagIndex = tag_idx+1
endfunction

" Push the tag to stack
function! PushTag(tag_name, tag_pattern, tag_filename)
    let win_idx = GetWindowNumber()
    let tag_idx = s:Window[win_idx].TagIndex
    let tag_type = GetStackTopTagType()
    let tag = copy(s:Tag)
    let tag.TagName = a:tag_name
	let tag.TagPattern = a:tag_pattern
    let tag.TagFileName = a:tag_filename
    let tag.CurPos = getpos(".")
    let tag.TagType = tag_type
    call add(s:Window[win_idx].TagStack, tag )
    let s:Window[win_idx].TagIndex = tag_idx+1
endfunction

" Pop the tag from stack
function! PopTag()
    let win_idx = GetWindowNumber()
    let tag_idx = s:Window[win_idx].TagIndex-1
    if tag_idx < 0 
        echo "Bottom of Stack"
        return 0
    endif
    let tag = copy(s:Window[win_idx].TagStack[tag_idx])
    call remove(s:Window[win_idx].TagStack, tag_idx)
    let s:Window[win_idx].TagIndex = tag_idx
    return tag
endfunction

" Get the top of the stack index
function! GetStackTopTagIndex()
    let win_idx = GetWindowNumber()
    let tag_idx = s:Window[win_idx].TagIndex
    return tag_idx
endfunction

" Get the top of the stack tag
function! GetStackTopTag()
    let win_idx = GetWindowNumber()
    let tag = copy(s:Window[win_idx].CurrentTag)
    return tag
endfunction

" Set the current top tag contents
function! SetStackTopTag(tag_name, tag_pattern, tag_filename, tag_type, line_no)
    let win_idx = GetWindowNumber()
    let s:Window[win_idx].CurrentTag.TagName = a:tag_name
    let s:Window[win_idx].CurrentTag.TagPattern = a:tag_pattern
    let s:Window[win_idx].CurrentTag.TagFileName = a:tag_filename
    let s:Window[win_idx].CurrentTag.CurPos = a:line_no
    let s:Window[win_idx].CurrentTag.TagType = a:tag_type
endfunction

" Get the tag type either FILE or TAG
function! GetStackTopTagType()
    let win_idx = GetWindowNumber()
    let tag_type = s:Window[win_idx].CurrentTag.TagType
    if tag_type == "NULL"
        let tag_type = "FILE"
    endif
    return tag_type
endfunction


" Debug functions
function! DisplayStackTopTag(index)
    let tag = copy(s:Window[a:index].CurrentTag)
    call DisplayTag(tag)
endfunction

" Debug functions
function! DisplayTag(tag)
    echo printf(" %-30.30s | %-9s | %-5s | %s ",  a:tag.TagName, a:tag.TagType, a:tag.CurPos[1], a:tag.TagFileName ) 
endfunction

function! GetTagContent(tag)
    return printf("%-50s | %-9s | %-5s| %s\n", a:tag.TagFileName, a:tag.CurPos[1], a:tag.TagName, a:tag.TagType ) 
endfunction

" Init the stack
function! OpenStack(index)
    let s:Window[a:index].TagStack = copy(s:Stack)
    let s:Window[a:index].CurrentTag = copy(s:Tag)
    let s:Window[a:index].TagIndex = 0
endfunction

" Uninit  stack
function! CloseStack(index)
	"echoerr len(s:Window). ":". a:index
	if len(s:Window) <= 0
	elseif  len(s:Window[a:index].TagStack) > 0 
        call remove(s:Window[a:index].TagStack, 0, len(s:Window[a:index].TagStack)-1)
    endif
    let s:Window[a:index].TagStack = 0
    let s:Window[a:index].TagIndex = 0
endfunction

" Display the tag stack
function! DisplayStack(index)
    for i in range(len(s:Window[a:index].TagStack)-1, 0, -1)
        call DisplayTag( s:Window[a:index].TagStack[i] )
    endfor
endfunction

" Get the top of the stack
function! GetStackContent(index)
    let stack_content=""
    for i in range(len(s:Window[a:index].TagStack)-1, 0, -1)
        let stack_content .= GetTagContent( s:Window[a:index].TagStack[i] )
    endfor
    return stack_content
endfunction

" Get the window index for tag
function! OpenWindow(index)
    if a:index > len(s:Window) 
        echoerr "Open: Out of index = ".a:index. ",len=". len(s:Window)
        return
    endif
    call insert(s:Window, copy(s:TagStack), a:index )
    call OpenStack(a:index)
endfunction

" Uninitialize the window 
function! CloseWindow(index)
    if a:index >= len(s:Window) || a:index < 1 
        echo "Close: Out of index = ".a:index. ",len=". len(s:Window)
        return
    endif
    call CloseStack(a:index)
    call remove(s:Window, a:index )
endfunction

" Initialize the new window
function! AddWindow()
    call add(s:Window, copy(s:TagStack))
    call OpenStack(len(s:Window)-1)
endfunction

" Window debug function
function! DisplayWindow()
    for i in range(1, len(s:Window)-1)
        echo "Window[".i."] TagIndex = ".s:Window[i].TagIndex
    endfor
endfunction

" Debug function to display the tag stack
function! DisplayWindowStack()
    for i in range(1, len(s:Window)-1)
        echo "Window[".i."] TagIndex = ".s:Window[i].TagIndex
        echo "-------------------------------------Tag Top Stack--------------------------------"
        call DisplayStackTopTag(i)
        echo "-------------------------------------Tag Stack------------------------------------"
        call DisplayStack(i)
    endfor
endfunction

" Select the tag from window tag stack
function! SelectWindowStackTag()
    let win_idx = GetWindowNumber()
    let stack_content = GetStackContent(win_idx)
    if stack_content == ""
        echohl WarningMsg | echo "Stack is Empty" | echohl None
        return
    endif
    call OpenTag("StackTag", "StackTag", stack_content)
endfunction



" Setup the buffer for window
let s:loadmsg=""
let s:Event={"LastEvent":"NULL", "LastWinCount":0, "LastWinNo":1 }
function! EnterBufWindow()
    if  s:Event.LastWinCount > winnr("$")
        call CloseWindow(s:Event.LastWinNo)
    endif

    if s:Event.LastWinCount  == 0
        call OpenWindow(s:Event.LastWinNo)
    endif

    let s:Event.LastWinCount = winnr("$")
    let s:Event.LastWinNo = winnr()
endfunction

" Setup the window for tag
function! EnterWindow()
    if  s:Event.LastWinCount > winnr("$")
        call CloseWindow(s:Event.LastWinNo)
    endif
    let s:Event.LastWinCount = winnr("$")
    let s:Event.LastWinNo = winnr()
endfunction

function! RemoveStack(index)
    for i in range(len(s:Window[a:index].TagStack)-1, 0, -1)
        call CloseTag()
    endfor
endfunction

function! LeaveVim()
    for i in range(1, len(s:Window)-1)
        "echo "Window[".i."] TagIndex = ".s:Window[i].TagIndex
		call RemoveStack( i )
    endfor
endfunction

" clearup while leaving from window
function! LeaveWindow()
    if s:Event.LastWinCount < winnr("$")
        call OpenWindow(s:Event.LastWinNo)
    endif
    if s:Event.LastWinCount > winnr("$")
        call CloseWindow(s:Event.LastWinNo)
    endif
    let s:Event.LastEvent = "Leave"
    let s:Event.LastWinCount = winnr("$")
    let s:Event.LastWinNo = winnr()

endfunction

"window debug message
function! LoadMsg()
    echo "Num of win =". s:loadmsg
    echo "Len = ".len(s:Window)
endfunction

autocmd BufWinEnter    * :call EnterBufWindow()
autocmd WinEnter       * :call EnterWindow()
autocmd WinLeave       * :call LeaveWindow()
"autocmd VimLeave       * :call LeaveVim()

let loaded_gtags_multi_window = 1



function! Gtags_x(arg)
    let l:pattern = a:arg
    call s:ExecLoad('dx --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction


function! Gtags_cx(arg)
    let l:pattern = a:arg 
    call s:ExecLoad('cdx --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction

function! Gtags_p(arg)
    let l:pattern = a:arg
    call s:ExecLoad('Po --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction

function! Gtags_r(arg)
    let l:pattern = a:arg
    call s:ExecLoad('rx --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction

function! Gtags_rx(arg)
    let l:pattern = a:arg
    call s:ExecLoad('rx --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction

function! Gtags_s(arg)
    let l:pattern = a:arg
    call s:ExecLoad('sx --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction

function! Gtags_g(arg)
    let l:pattern = a:arg
    call s:ExecLoad('gx --result=ctags-mod', '', l:pattern, l:pattern, ' ')
endfunction

"function! Gtags_e(arg)
    "let l:pattern = input("X-PATTERN:")
    "call s:ExecLoad('sx  --result=ctags-mod', '', l:pattern, l:pattern, ' ')
"endfunction





function! GtagsCustomComplete(option, lead)
    if a:option == 'g'
        return ''
    elseif a:option == 'f'
        if isdirectory(a:lead)
            if a:lead =~ '/$'
                let l:pattern = a:lead . '*'
            else
                let l:pattern = a:lead . '/*'
            endif
        else
            let l:pattern = a:lead . '*'
        endif
        return glob(l:pattern)
    else 
        return system('global  ' . '-c' . a:option . ' ' . a:lead)
    endif
endfunction




function! GtagsComplete_x(arg, line, pos)
	return GtagsCustomComplete('x', a:arg)
endfunction
function! GtagsAutoComplete_x()
	let l:line = input("X-PATTERN:", "", 'custom,GtagsComplete_x')
	if(l:line != "")
		call Gtags_x(l:line)
	endif
endfunc
exec " noremap " . g:gtags_cmd_open_definition . " :call GtagsAutoComplete_x() <CR>"
exec "inoremap " . g:gtags_cmd_open_definition . " <ESC> :call GtagsAutoComplete_x() <CR>"


function! GtagsComplete_r(arg, line, pos)
	return GtagsCustomComplete('rx', a:arg)
endfunction
function! GtagsAutoComplete_r()
	let l:line = input("R-PATTERN:", "", 'custom,GtagsComplete_r')
	if(l:line != "")
		call Gtags_r(l:line)
	endif
endfunc
exec "  noremap " . g:gtags_cmd_open_reference	. "	:call GtagsAutoComplete_r() <CR>"
exec " inoremap " . g:gtags_cmd_open_reference	. "	<ESC> :call GtagsAutoComplete_r() <CR>"




function! GtagsComplete_s(arg, line, pos)
	return GtagsCustomComplete('sx', a:arg)
endfunction
function! GtagsAutoComplete_s()
	let l:line = input("S-PATTERN:", "", 'custom,GtagsComplete_s')
	if(l:line != "")
		call Gtags_s(l:line)
	endif
endfunc


function! GtagsComplete_c(arg, line, pos)
	return GtagsCustomComplete('ldx', a:arg)
endfunction
function! GtagsAutoComplete_l()
	let l:line = input("S-PATTERN:", "", 'custom,GtagsComplete_c')
	if(l:line != "")
		call Gtags_cx(l:line)
	endif
endfunc
"noremap <C-f><C-l>  :call GtagsAutoComplete_l() <CR>
"inoremap <C-f><C-l> <ESC> :call GtagsAutoComplete_l() <CR>





function! GtagsComplete_p(arg, line, pos)
	return GtagsCustomComplete('iPx', a:arg)
endfunction
function! GtagsAutoComplete_p()
	let l:line = input("P-PATTERN:", "", 'custom,GtagsComplete_p')
	if(l:line != "")
		call Gtags_p(l:line)
	endif
endfunc
exec "  noremap	" .	g:gtags_cmd_open_file_path	. " :call GtagsAutoComplete_p() <CR>"
exec " inoremap	" . g:gtags_cmd_open_file_path	. " <ESC> :call GtagsAutoComplete_p() <CR>"




function! GtagsAutoComplete_cp()
	let l:input = expand("%:t")
	call Gtags_p(l:input )
endfunc
"noremap <C-f><C-e>  :call GtagsAutoComplete_cp() <CR>
"inoremap <C-f><C-e> <ESC>:call GtagsAutoComplete_cp() <CR>





function! GtagsAutoComplete_raw_string_search()
	let l:input = input("STRING-PATTERN:")
	if(l:input == '') 
		return 
	endif
    let l:pattern = substitute(l:input, '[~!@#$%^&*()\-_=\+\[{\]}\|;:",\./\?]', '\\&', "g")
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
	"let l:pattern = shellescape(l:pattern)
	"echoerr "[". l:pattern."]"
    call s:ExecLoad('gx  --result=ctags-mod', '', l:pattern, "STRING_SEARCH", ' ')
endfunction
exec "noremap ". g:gtags_open_raw_string_search ." :call GtagsAutoComplete_raw_string_search() <CR>"
exec "inoremap ". g:gtags_open_raw_string_search ." :call GtagsAutoComplete_raw_string_search() <CR>"


function! GtagsAutoComplete_grep_search()
	let l:input = input("GREP-PATTERN:")
	if(l:input == '') 
		return 
	endif
	let l:pattern = l:input
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
    call s:ExecLoad('ogx --result=ctags-mod', '', l:pattern, "GREP_SEARCH", ' ')
endfunction
exec "noremap ". g:gtags_cmd_open_grep_search ." :call GtagsAutoComplete_grep_search() <CR>"
exec "inoremap ". g:gtags_cmd_open_grep_search ." :call GtagsAutoComplete_grep_search() <CR>"


"----------------------------------------
"             SUB SEARCH 
"----------------------------------------
let s:result=[]
function! Update( file, no, pattern, search)
	
	let tag = GetStackTopTag()
    if tag.TagType == "TAG" 
		let data = a:search
	else
		"let data = a:file. "\t".a:no."\t". a:search
		let data = substitute(a:search, '^[ \t]*', '', "g")
		let data = printf("%-30s  |%4d|  %s", a:file, a:no, data)
	endif
	call add(s:result, data)
endfunc

function! s:SearchFile(search_type, pattern)
	let s:result=[]
	"let tag = GetStackTopTag()
	let l:line_no = getpos(".")
	execute  a:search_type. "/".escape(a:pattern, "/")."/ call Update( bufname(\"%\") ,  line(\".\") ,  \"".a:pattern."\", getline(\".\") )"
    call setpos(".", l:line_no)

	if len(s:result)>0
		"call CopyCurrentToStackTop()
		"call PushTag(a:pattern, a:pattern, bufname("%"))
		call SetStackTopTag("SEARCH", "SEARCH", bufname("%"), "FILE", l:line_no)
		call OpenTag("SEARCH", a:pattern, s:result)
	endif
endfunc


let s:sresult=[]
function! UpdateCompletion(pattern, search)
	let data = substitute(a:search, '.*\('.a:pattern.'[^ \t]*.\)\(.\{1,20\}\).*', '\1\2', "g")
	"echoerr data
	call add(s:sresult, data)
endfunction

function! GtagsComplete_subsearch(pattern, line, pos)
	let s:sresult=[]
	let l:line_no = getpos(".")
	"let l:line_no = getcurpos()
	execute "g/".escape(a:pattern, "/")."/ call UpdateCompletion( \"".a:pattern."\", getline(\".\") )"
    call setpos(".", l:line_no)
	let out = join(s:sresult, "\n")
	"echoerr out
	return out
endfunction



function! GtagsAutoComplete_subg()
	let l:input = input("SUB-PATTERN:", "", "custom,GtagsComplete_subsearch")
	if(l:input == '') 
		return 
	endif

	let l:pattern = l:input

	let l:pattern = substitute(l:pattern, '^.', '', "g")

	let search_type = l:input[0]

	if search_type == '~'
		call s:SearchFile("v", l:pattern)
	else
		call s:SearchFile("g", l:input)
	endif

endfunc
exec " noremap	" . g:gtags_cmd_sub_string_search . " :call GtagsAutoComplete_subg() <CR>"
exec " inoremap " . g:gtags_cmd_sub_string_search . " <ESC> :call GtagsAutoComplete_subg() <CR>"



" VIM / SEARCH
let s:vresult=[]
function! UpdateVimCompletion(pattern, search)
	let data = substitute(a:search, '.*\('.a:pattern.'[^ \t]*.\)\(.\{1,20\}\).*', '\1\2', "g")
	"echoerr data
	call add(s:vresult, data)
endfunction

function! GtagsComplete_vimsearch(pattern, line, pos)
	let s:vresult=[]
	let l:line_no = getcurpos()
	execute "g/".escape(a:pattern, "/")."/ call UpdateVimCompletion( \"".a:pattern."\", getline(\".\") )"
    call setpos(".", l:line_no)
	let out = join(s:vresult, "\n")
	"echoerr out
	return out
endfunction
function! GtagsAutoComplete_vimsearch()
	let l:input = input("./", "", "custom,GtagsComplete_vimsearch")
	call search( l:input )
endfunc

"noremap ./ :call GtagsAutoComplete_vimsearch()<CR>





function! GtagsAutoComplete_subd()
	let l:input = input("DIRS-PATTERN:")
	if(l:input == '') 
		return 
	endif

    let l:pattern = substitute(l:input, '[~!@#$%^&*()\-_=\+\[{\]}\|;:",\./\?]', '\\&', "g")
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
    call s:ExecLoad('lgx  --result=ctags-mod', '', l:pattern, "STRING_SEARCH", ' ')

endfunc

function! GtagsAutoComplete_subd_grep()
	let l:input = input("DIRS-GREP-PATTERN:")
	if(l:input == '') 
		return 
	endif
	let l:data = split(l:input, "|")
	"echoerr l:data[0]
	execute "cd ".l:data[0]
    let l:pattern = substitute(l:data[1], '[~!@#$%^&*()\-_=\+\[{\]}\|;:",\./\?]', '\\&', "g")
    let l:pattern = substitute(l:pattern, '['']', '.', "g")
    call s:ExecLoad('lgx --result=ctags-mod', '', l:pattern, "STRING_SEARCH", ' ')

endfunc




function! GtagsSearchReplace()
	let tag=GetStackTopTag()
    if tag.TagType == "TAG" 
		let l:find = input("FIND-PATTERN:", tag.TagPattern)
		if(l:find == '') 
			return 
		endif
		let l:replace = input("REPLACE-PATTERN:")
		if(l:replace == '') 
			return 
		endif
		let lines = getbufline(bufnr(tag.TagFileName), 2, "$")
		let i=0
		while i < (len(lines))
			let word=split(lines[i], "[\t|]")
			call ViewBuffer("", word[0], "")
			try
				execute  "".word[1]."s/".l:find."/".l:replace."/gc "
				"let res = input("contine?")
				"if(res != 'y')
					"let i=i-2
				"endif
			catch 
			endtry
			let i=i+1
		endwhile
		"call ECHO("LOADING>...", tag.TagFileName)
		call ViewBuffer("", tag.TagFileName, "")
	endif

endfunc
exec "  noremap	" . g:gtags_cmd_search_and_replace	. "	:call GtagsSearchReplace() <CR>"
exec " inoremap	" . g:gtags_cmd_search_and_replace	. "	<ESC>:call GtagsSearchReplace() <CR>"


function! GtagsLoadFileFromLine()
	let words = split(getline("."), '[ \t]')
	let file_name=words[0]
	let pattern=expand("%:p:t")
	call PushTag(pattern, pattern, bufname("%"))
	call LoadBuffer(pattern, pattern, file_name, 1, "FILE", "")
endfunc

exec " noremap	" .	g:gtags_cmd_view_cursor_file . " :call GtagsLoadFileFromLine() <CR>"
exec " inoremap	" . g:gtags_cmd_view_cursor_file . " <ESC>:call GtagsLoadFileFromLine() <CR>"





"TODO:  
" Local folder search, variable search
" Open New search from old search result
" v <empty>, ctl+P for filesearch
" dir diff
"
" Shortcut keys customization 
" ag to kg changes
" Custom alias and key mappings
" partial kg serach "cd fabos/src/hasm; kg txt
" help text popup for all prototype
" try/catch for tags errors
" Progress
