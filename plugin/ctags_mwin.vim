"----------------------------------------
"             CTAGS/CSCOPE SEARCH
"             Inspired by:
"
"             https://github.com/vim-scripts/cscope_win/blob/master/plugin/cscope_win.vim
"             https://github.com/vim-scripts/acsb/blob/master/README.orig
"             https://github.com/jlanzarotta/bufexplorer/blob/master/plugin/bufexplorer.vim
"
"             https://searchcode.com/codesearch/view/77464705/
"             https://stackoverflow.com/questions/14915971/cscope-how-to-use-cscope-to-search-for-a-symbol-using-command-line
"             https://www.vim.org/scripts/script.php?script_id=1076
"----------------------------------------
if exists("g:loaded_cscope_mappings") || v:version < 700 || &cp
  "finish
endif
let g:loaded_cscope_mappings = 1

let s:results=[]

function! ExecCscopeCmd(option,var)
    let l:results = ''
    "let l:cs_executable = get(split(g:cs_prg, " "), 0)
    let l:srch = '"'.a:var.'"'

    "check the cscope program
    "check for cscope.out file in the path
    let db = findfile("cscope.out", '.;')
    if empty(db)
        echo " Error:Cscope Database Not Found....."
    endif

    "If no pattern is provided, return
    if empty(a:var)
        return
    endif

    try
        "let cs_cmd=&csprg . cs_ic_option . " -d -L -f " . s:cscope_{i}_db_filename . " -" . a:option . a:var . " | sort -k 3,3 -g | sort -s -k 1,1"
        "let cs_cmd=&csprg " -d -L -f  cscope.out " " -". a:option . a:var . " | sort -k 3,3 -g | sort -s -k 1,1"
        "let l:cs_cmd = &csprg." -d -L -f  cscope.out "." -". a:option . " " .a:var . " | sort -k 3,3 -g | sort -s -k 1,1"
        let l:cs_cmd = &csprg." -d -L -f  cscope.out "." -". a:option . " " .a:var
        "echo l:cs_cmd
        "echoerr "CMD = ".l:cs_cmd
        let l:results = system(l:cs_cmd)
    endtry
    "echoerr l:results
    let output = l:results
    let s:results=[]
    while output != ''
        let line_pos=stridx(output,"\n")
        "entire line
        let curr_line=strpart(output, 0, line_pos)

        if match(curr_line,'\S\+\s\+\S\+\s\+\d\+\s\+.*')==-1
            let output=strpart(output,line_pos+1)
            continue
        endif

        "extract file complete path
        let idx=stridx(curr_line," ")
        let full_path=strpart(curr_line,0,idx)
"echo full_path

        let file_name=fnamemodify(full_path,":t")
        let term_slash=''
        "shift line to next field
        let curr_line=strpart(curr_line,idx+1)
"echo curr_line

        "extract sym
        let idx=stridx(curr_line," ")
        let sym=strpart(curr_line,0,idx)

        if match(sym,"<.*>")==-1
            let sym="<" . sym . ">"
        endif
"echo sym

        "shift line to next field
        let curr_line=strpart(curr_line,idx+1)

        "extract line number
        let idx=stridx(curr_line," ")
        let line_num=strpart(curr_line,0,idx)
"echo line_num

        "shift line to next field
        let descr=strpart(curr_line,idx+1)
        let output=strpart(output,line_pos+1)
"echo descr

        let num_str="[".line_num."]"
        let wspace_len=7-strlen(num_str)
        if wspace_len<1
            let wspace_len=1
        endif
        let wspace_str=strpart("       ",0,wspace_len)
        let app_str=wspace_str.num_str . " " . sym
        let wspace_len=40-strlen(app_str)
        if wspace_len<1
            let wspace_len=1
        endif
        let wspace_str=strpart("                                        ",0,wspace_len)
        "call append(count1,app_str . wspace_str . descr)
        "let count1=count1+1
        let prev_path=full_path


        let data = printf("%-30s  |%4d| %s| %s", full_path, line_num, sym, descr )
        "echo data
        call add(s:results, data)

    endwhile

    if l:results != ''
        call OpenTag("SEARCH_CSCOPE", a:var, s:results )
        "call OpenTag(a:var, a:option, s:results )
        "call OpenTag(a:var, "SEARCH_CSCOPE", s:results )
    else
        echom 'No matches for "'.a:var.'"'
    endif
endfunction

"       +----------------------------------------------------------+
"       | CMD                          ACTION                      |
"       +----------------------------------------------------------+
"       |0<str>   Find this C symbol:                              |
"       |1<str>   Find this definition:                            |
"       |2<str>   Find functions called by this function:          |
"       |3<str>   Find functions calling this function:            |
"       |4<str>   Find assignments to:                             |
"       |5<str>   Change this grep pattern:                        |
"       |6<str>   Find this egrep pattern:                         |
"       |7<str>   Find this file:                                  |
"       |8<str>   Find files #including this file:                 |
"       +----------------------------------------------------------+
"       |9<str>   Find all function/class definitions (samuel)     |
"       |:<str>   Find all function/class definitions (cdb)        |
"       +----------------------------------------------------------+
"       |a<str>   Set  the directory search pattern for 'Find this |
"       |         egrep pattern'.  This is the equivalent  of  the |
"       |         command line option of -a                        |
"       |^<str>   Set the directory filter pattern for all queries |
"       |c        Toggle Caseless mode                             |
"       |C        Clear file names                                 |
"       |F        Add file name                                    |
"       |P        Print the path to the files                      |
"       |r        rebuild the database cscope style                |
"       |R        rebuild the database samuel style                |
"       +----------------------------------------------------------+
"       |q        Quit                                             |
"       +----------------------------------------------------------+
"       |         (used by ccalls with the extended menu)          |
"       |0<str>   Find this type definition:                       |
"       |1<str>   Find this preprocessor definition:               |
"       |2<str>   Find parameters of this function:                |
"       |3<str>   Find functions calling this function:            |
"       |4<str>   Find this global definition:                     |
"       |5<str>   Find this local definition:                      |
"       |6<str>   Find this structure definition:                  |
"       |7<str>   Find this file:                                  |
"       |8<str>   Find this preprocessor include:                  |
"       |9<str>   Find definition of this function:                |
"       |:<str>   Find all function/class definitions:             |
"       +----------------------------------------------------------+

function! ExecCscopeSubCmd(option, val)
    call ExecCscopeCmd(a:option, a:val)

    "if (s:results == '') && (a:option=='1')
    "    call ExecCscopeCmd('0', a:val)

endfunction

function! CsHandleCsOption(option)
    if((a:option=='f') || (a:option=='i'))
        let ident=expand("<cfile>:t")
    else
        let ident=expand("<cword>")
    endif

    call ExecCscopeSubCmd(a:option,ident)
endfunction

function! CsHandleCsOptionInteract(option)
    let l:str = "CS-PATTERN(".a:option."):"
    if (a:option=='s') || (a:option=='0')
        let l:str = "CS-SYMBOL :"
    elseif (a:option=='g') || (a:option=='1')
        let l:str = "CS-DEFINATION :"
    elseif (a:option=='d') || (a:option=='2')
        let l:str = "CS-CALL-SEARCH :"
    elseif (a:option=='c') || (a:option=='3')
        let l:str = "CS-CALLER-SEARCH :"
    elseif (a:option=='t') || (a:option=='4')
        let l:str = "CS-STRING-SEARCH :"
    elseif (a:option=='e') || (a:option=='6')
        let l:str = "CS-PATTERN-SEARCH :"
    elseif (a:option=='f') || (a:option=='7')
        let l:str = "CS-FILE-SEARCH :"
    endif
    let l:input = input(l:str)
	if(l:input == '')
		return
	endif

    call ExecCscopeSubCmd(a:option,l:input)
endfunction

function! Cs_s(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('0',l:pattern)
endfunction

function! Cs_g(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('1',l:pattern)
endfunction

function! Cs_d(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('2',l:pattern)
endfunction

function! Cs_c(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('3',l:pattern)
endfunction

function! Cs_t(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('4',l:pattern)
endfunction

function! Cs_e(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('6',l:pattern)
endfunction

function! Cs_f(arg)
    let l:pattern = a:arg
    call ExecCscopeSubCmd('7',l:pattern)
endfunction

if !exists("g:cscope_mappings")
    let g:ctags_mwin_mappings = 1
endif

if g:ctags_mwin_mappings == 0
    finish
endif

let g:ctags_mwin_mappings = 1

if !exists("g:cs_cmd_def_search")
let g:cs_cmd_def_search = "<leader>g <cr>"
endif
if !exists("g:cs_cmd_sym_search")
let g:cs_cmd_sym_search = "<leader>s <cr>"
endif
if !exists("g:cs_cmd_calling_search")
let g:cs_cmd_calling_search = "<leader>d <cr>"
endif
if !exists("g:cs_cmd_called_search")
let g:cs_cmd_calledby_search = "<leader>c <cr>"
endif
if !exists("g:cs_cmd_text_search")
let g:cs_cmd_text_search = "<leader>t <cr>"
endif
if !exists("g:cs_cmd_egrep_search")
let g:cs_cmd_egrep_search = "<leader>e <cr>"
endif
if !exists("g:cs_cmd_file_search")
let g:cs_cmd_file_search = "<leader>f <cr>"
endif
if !exists("g:cs_cmd_ref_search")
let g:cs_cmd_ref_search = "<leader>ss <cr>"
endif

exec " noremap " . g:cs_cmd_def_search . " :call CsHandleCsOption('1')<cr>"
exec " noremap " . g:cs_cmd_sym_search . " :call CsHandleCsOption('0') <CR>"
exec " noremap " . g:cs_cmd_calling_search . " :call CsHandleCsOption('2') <CR>"
exec " noremap " . g:cs_cmd_calledby_search . " :call CsHandleCsOption('3') <CR>"
exec " noremap " . g:cs_cmd_text_search . " :call CsHandleCsOptionInteract('4') <CR>"
exec " noremap " . g:cs_cmd_egrep_search . " :call CsHandleCsOptionInteract('6') <CR>"
exec " noremap " . g:cs_cmd_file_search . " :call CsHandleCsOptionInteract('7') <CR>"
exec " noremap " . g:cs_cmd_ref_search . " :call CsHandleCsOptionInteract('0') <CR>"




function CtagsSetTags()
    let curdir = getcwd()

    while !filereadable("tags") && getcwd() != "/"
        cd ..
    endwhile

    if filereadable("tags")
        execute "set tags=" . getcwd() . "/tags"
    endif

    execute "cd " . curdir
endfunction

function CsSetCscope()
    let curdir = getcwd()

    while !filereadable("cscope.out") && getcwd() != "/"
        cd ..
    endwhile

    if filereadable("cscope.out")
        execute "cs add " . getcwd() . "/cscope.out"
    endif

    execute "cd " . curdir
endfunction

function s:CsFindFile(file)
    let curdir = getcwd()
    let found = curdir
    while !filereadable(a:file) && found != "/"
        cd ..
        let found = getcwd()
    endwhile
    execute "cd " . curdir
    return found
endfunction

if has('cscope')
    set csto=0
    set cst
    set nocsverb

    let $CSCOPE_DIR=s:CsFindFile("cscope.out")
    let $CSCOPE_DB=$CSCOPE_DIR."/cscope.out"
    if filereadable($CSCOPE_DB)
        cscope add $CSCOPE_DB $CSCOPE_DIR
    endif

    command -nargs=0 CsCscope !cscope -ub -R &
endif

"call SetTags()
"call SetCscope()



