
if exists("tagstack_helper")
    finish
endif
let tagstack_helper = 1
set hidden

highlight GtagsHeader cterm=bold  ctermbg=24 ctermfg=255
highlight GtagsGroup  cterm=bold  ctermbg=24 ctermfg=255
highlight GtagsProgressFile cterm=bold  ctermbg=none ctermbg=230

if g:tagstack_key_map_enable == 1

let g:No_Gtags_Multi_Window_Auto_Map = 0
let g:gtags_open_navigation_path        = '<C-D>'
let g:gtags_close_tag                   = '<C-T>'
let g:gtags_cmd_open_kg_search      = '<C-F><C-F>'
let g:gtags_cmd_open_ak_search      = '<C-Y><C-Y>'
let g:gtags_cmd_sub_string_search   = '<C-S><C-S>'

if g:tagging_system == 1 "Gtags

let g:No_Gtags_Multi_Window_Auto_Map = 0
let g:gtags_open_definition				= '<C-\>'
let g:gtags_open_definition_left_hand	= '<C-E>'
let g:gtags_open_definition_ctags_stype = '<C-]>'
let g:gtags_open_reference				= '<C-R>'
let g:gtags_open_local_sym_reference	= '<C-S>'
let g:gtags_open_raw_string_search		= '<C-G>'

let g:gtags_cmd_open_definition		= '<C-X><C-X>'
let g:gtags_mouse_open_definition	= '<C-LeftMouse>'
let g:gtags_cmd_open_reference		= '<C-R><C-R>'
let	g:gtags_cmd_open_grep_search	= '<C-G><C-G>'
let	g:gtags_cmd_open_file_path		= '<C-P><C-P>'
let	g:gtags_cmd_search_and_replace	= '<C-F><C-R>'
let	g:gtags_cmd_view_cursor_file	= '<C-F><C-L>'
let g:gtags_cmd_open_ak_search      = '<C-Y><C-Y>'

elseif g:tagging_system == 2 "Cscope

let g:ctags_mwin_mappings = 1
let g:cs_cmd_def_search         = '<C-\>'
let g:cs_cmd_sym_search         = '<C-R>'
let g:cs_cmd_calling_search     = '<C-S>'
let g:cs_cmd_calledby_search    = '<M-h>'
let g:cs_cmd_text_search        = '<C-G>'
let g:cs_cmd_egrep_search       = '<C-G><C-G>'
let g:cs_cmd_file_search        = '<C-P>'
let g:cs_cmd_ref_search         = '<C-R><C-R>'

elseif g:tagging_system == 3 "Both
let g:No_Gtags_Multi_Window_Auto_Map = 0
let g:gtags_open_definition				= '<C-\>'
let g:gtags_open_definition_left_hand	= '<C-E>'
let g:gtags_open_definition_ctags_stype = '<C-]>'
let g:gtags_open_reference				= '<C-R>'
let g:gtags_open_local_sym_reference	= '<C-S>'
let g:gtags_open_raw_string_search		= '<C-G>'

let g:gtags_cmd_open_definition		= '<C-X><C-X>'
let g:gtags_mouse_open_definition	= '<C-LeftMouse>'
let g:gtags_cmd_open_reference		= '<C-R><C-R>'
let	g:gtags_cmd_open_grep_search	= '<C-G><C-G>'
let	g:gtags_cmd_open_file_path		= '<C-P><C-P>'
let	g:gtags_cmd_search_and_replace	= '<C-F><C-R>'
let	g:gtags_cmd_view_cursor_file	= '<C-F><C-L>'
let g:gtags_cmd_open_ak_search      = '<C-Y><C-Y>'

let g:ctags_mwin_mappings = 1
let g:cs_cmd_def_search         = '<M-s>'
let g:cs_cmd_sym_search         = '<M-q>'
let g:cs_cmd_calling_search     = '<M-h><M-h>'
let g:cs_cmd_calledby_search    = '<M-h>'
let g:cs_cmd_text_search        = '<M-g>'
let g:cs_cmd_egrep_search       = '<M-g><M-g>'
let g:cs_cmd_file_search        = '<M-p>'
let g:cs_cmd_ref_search         = '<M-q><M-q>'

endif
"CTAGS
noremap ] :cstag <C-R>=expand("<cword>")<CR><CR>
noremap t :pop <CR><CR>
nnoremap <M-d> :tag<CR>
nmap <C-B> :cstag <C-R>=expand("<cword>")<CR><CR>
nmap <M-t> :pop <CR><CR>

endif
