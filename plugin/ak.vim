" NOTE: You must, of course, install ak1 / the_silver_searcher
"command! -bang -nargs=* -complete=file Ksearch call ak1#GtagsAck('ak1<bang>',<q-args>)




"command! -bang -nargs=* -complete=file AgBuffer call ag#AgBuffer('grep<bang>',<q-args>)
"command! -bang -nargs=* -complete=file AgAdd call ag#Ag('grepadd<bang>', <q-args>)
"command! -bang -nargs=* -complete=file AgFromSearch call ag#AgFromSearch('grep<bang>', <q-args>)
"command! -bang -nargs=* -complete=file LAg call ag#Ag('lgrep<bang>', <q-args>)
"command! -bang -nargs=* -complete=file LAgBuffer call ag#AgBuffer('lgrep<bang>',<q-args>)
"command! -bang -nargs=* -complete=file LAgAdd call ag#Ag('lgrepadd<bang>', <q-args>)
"command! -bang -nargs=* -complete=file AgFile call ag#Ag('grep<bang> -g', <q-args>)
"command! -bang -nargs=* -complete=help AgHelp call ag#AgHelp('grep<bang>',<q-args>)
"command! -bang -nargs=* -complete=help LAgHelp call ag#AgHelp('lgrep<bang>',<q-args>)

function! GtagsAckSearch()
	let l:input = input("ACKSEARCH-PATTERN:", "")
	if(l:input == '') 
		return 
	endif
	"echoerr "[".l:input. "]"
    "Rashmi
    if !executable(g:akprg)
        echoe "Ack Program '" . g:akprg . "' was not found. Check as this come from as veriable g:akprg from VIMRC"
    endif
	call ak#GtagsAck( g:akprg, l:input)
endfunction

if !exists('gtags_cmd_open_ak_search')
    let gtags_cmd_open_ak_search = '<leader><C-F><C-F>'
endif

"exec "noremap  ". g:gtags_cmd_open_ak1_search ."  :Ksearch  \"\"<left>"
"exec "inoremap ". g:gtags_cmd_open_ak1_search ."  <ESC> :Ksearch \"\"<left>"

 " :call GtagsAutoComplete_subg() <CR>"
exec "noremap  ". g:gtags_cmd_open_ak_search ." :call GtagsAckSearch() <CR>"
exec "inoremap ". g:gtags_cmd_open_ak_search ." <ESC>:call GtagsAckSearch() <CR>"


