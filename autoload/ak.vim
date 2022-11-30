" NOTE: You must, of course, install ak / the_silver_searcher

" FIXME: Delete deprecated options below on or after 15-7 (6 months from when they were changed) {{{

if exists("g:akprg")
  let g:ak_prg = g:akprg
endif

if exists("g:akhighlight")
  let g:ak_highlight = g:akhighlight
endif

if exists("g:akformat")
  let g:ak_format = g:akformat
endif

" }}} FIXME: Delete the deprecated options above on or after 15-7 (6 months from when they were changed)

" Location of the ak utility
if !exists("g:ak_prg")
  " --vimgrep (consistent output we can parse) is available from version  0.25.0+
  if split(system("ack --version"), "[ \n\r\t]")[2] =~ '\d\+.[2-9][5-9]\(.\d\+\)\?'
    let g:ak_prg="ack --column"
  else
    " --noheading seems odd here, but see https://github.com/ggreer/the_silver_searcher/issues/361
    let g:ak_prg="ack --column --nogroup --noheading"
  endif
endif

if !exists("g:ak_apply_qmappings")
  let g:ak_apply_qmappings=1
endif

if !exists("g:ak_apply_lmappings")
  let g:ak_apply_lmappings=1
endif

if !exists("g:ak_qhandler")
  let g:ak_qhandler="botright copen"
endif

if !exists("g:ak_lhandler")
  let g:ak_lhandler="botright lopen"
endif

if !exists("g:ak_mapping_messake")
  let g:ak_mapping_message=1
endif

function! ak#AckBuffer(cmd, args)
  let l:bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let l:files = []
  for buf in l:bufs
    let l:file = fnamemodify(bufname(buf), ':p')
    if !isdirectory(l:file)
      call add(l:files, l:file)
    endif
  endfor
  call ak#Ack(a:cmd, a:args . ' ' . join(l:files, ' '))
endfunction

function! ak#GtagsAck(cmd, args)
	"echoe "Ack command rashmi"
	call ak#Ack(a:cmd . " --nocolumn --nogroup --noheading ", a:args)
	"echoe " ". a:cmd ." ".a:args.""
endfunc

function! ak#Ack(cmd, args)
    let l:results = ''
  let l:ak_executable = get(split(g:ak_prg, " "), 0)
  let l:srch = '"'.a:args.'"'

  " Ensure that `ak` is installed
  if !executable(l:ak_executable)
    echoe "Ack command '" . l:ak_executable . "' was not found. Is the silver searcher installed and on your $PATH?"
    "return
  endif

  " If no pattern is provided, search for the word under the cursor
  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = l:srch . join(a:000, ' ')
  end

  " Format, used to manage column jump
  if a:cmd =~# '-g$'
    let s:ak_format_bakup=g:ak_format
    let g:ak_format="%f"
  elseif exists("s:ak_format_bakup")
    let g:ak_format=s:ak_format_bakup
  elseif !exists("g:ak_format")
    let g:ak_format="%f:%l:%c:%m"
  endif

	"echoerr l:ak_executable."-".a:cmd
  let l:grepprg_bak=&grepprg
  let l:grepformat_bak=&grepformat
  let l:t_ti_bak=&t_ti
  let l:t_te_bak=&t_te
  try
    let &grepprg=g:ak_prg
    let &grepformat=g:ak_format
    set t_ti=
    set t_te=
	"echoerr a:cmd . " " . escape(l:grepargs, '|')
    let l:results=system(a:cmd . " " . escape(l:grepargs, '|'))
  finally
    let &grepprg=l:grepprg_bak
    let &grepformat=l:grepformat_bak
    let &t_ti=l:t_ti_bak
    let &t_te=l:t_te_bak
  endtry

	"echoerr l:results
  if l:results != ''
    call OpenTag("SEARCH", a:args, l:results )
  else
    echom 'No matches for "'.a:args.'"'
  endif
endfunction

function! ak#AckFromSearch(cmd, args)
  let search =  getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
  call ak#Ack(a:cmd, '"' .  search .'" '. a:args)
endfunction

function! ak#GetDocLocations()
  let dp = ''
  for p in split(&runtimepath,',')
    let p = p.'/doc/'
    if isdirectory(p)
      let dp = p.'*.txt '.dp
    endif
  endfor
  return dp
endfunction

function! ak#AckHelp(cmd,args)
  let args = a:args.' '.ak#GetDocLocations()
  call ak#Ack(a:cmd,args)
endfunction


