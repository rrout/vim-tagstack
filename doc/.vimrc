set tabstop=4
"set mouse=a
set t_Co=256
syntax on

function Main()
    call SetCustomVbundleSettings()
    call SetCustomGeneralSettings()
    call SetCustomLnguageSettings()
	call SetCustomColorSettings()
    call SetCustomCursorSettings()
	call SetCustomCursorLineSettings()
	call SetCustomBackgroundSettings()
	call SetCustomQuickFixWindowSettings()
	call SetCustomSearchSettings()
	call SetCustomHighlightSettings()
    call SetCustomAirlinePluginSettings()
    call SetCustomMarkPluginSettings()
    call SetCustomPluginSettings()
    call SetCustomBufferPositionSettings()
    call SetCustomIndentationSettings()
    call SetCustomMouseSettings()
    call SetCustomTabSpaceSettings()
	call SetCustomCompleteOptionSettings()
	"call SetCustomAutoRemoveTrailingwhiteSpaceSettings()
	call SetCustomOmniCompleteSettings()
	call SetCustomCtagsSettings()
	call SetCustomCscopeSettings()
	call SetCustomTestSettings()
	call SetCustomTagStackPluginSettings()
	"call SetCustomClangCompletePluginSettings()
	"call SetCustomWindowsLikeSaveFileSettings()
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Custom Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomGeneralSettings()
set ttimeout        " time out for key codes
set ttimeoutlen=100 " wait up to 100ms after Esc for special key
set ttimeoutlen=0   " Improve ESC press timeout (Slowness if ESC in Inser mode)
set ttyfast
"set autochdir		" Auto change the PWD
set hlsearch		" Highlight search
noremap U <ESC>:redo<CR>	"map :redo to <CAPS U>
endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Vbundle Configurations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomVbundleSettings()
set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'dimasg/vim-mark'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'nathanaelkane/vim-indent-guides'
"Plugin 'xavierd/clang_complete'
Plugin 'guns/xterm-color-table.vim'
Plugin 'rrout/vim-tagstack'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cursor
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomCursorSettings()
"Mode Settings
let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)
"Cursor settings:
"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar

highlight Cursor guifg=white guibg=black
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10
if &term =~ "xterm\\|rxvt"
  " use an orange cursor in insert mode
  let &t_SI = "\<Esc>]12;orange\x7"
  " use a red cursor otherwise
  let &t_EI = "\<Esc>]12;red\x7"
  silent !echo -ne "\033]12;red\007"
  " reset cursor when vim exits
  autocmd VimLeave * silent !echo -ne "\033]112\007"
  " use \003]12;gray\007 for gnome-terminal and rxvt up to version 9.21
endif
if &term =~ '^xterm\\|rxvt'
  " solid underscore
  let &t_SI .= "\<Esc>[4 q"
  " solid block
  let &t_EI .= "\<Esc>[2 q"
  " 1 or 0 -> blinking block
  " 3 -> blinking underscore
  " Recent versions of xterm (282 or above) also support
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar
endif
" tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
if exists('$TMUX')
   " set insert mode to a cyan vertical line
   let &t_SI .= "\<esc>Ptmux;\<esc>\<esc>[6 q\<esc>\\"
   let &t_SI .= "\<esc>Ptmux;\<esc>\<esc>]12;cyan\x7\<esc>\\"
   " set normal mode to a green block
   let &t_EI .= "\<esc>Ptmux;\<esc>\<esc>[2 q\<esc>\\"
   let &t_EI .= "\<esc>Ptmux;\<esc>\<esc>]12;green\x7\<esc>\\"
   " set replace mode to an orange underscore
   let &t_SR .= "\<esc>Ptmux;\<esc>\<esc>[4 q\<esc>\\"
   let &t_SR .= "\<esc>Ptmux;\<esc>\<esc>]12;orange\x7\<esc>\\"

   " initialize cursor shape/color on startup (silent !echo approach doesn't seem to work for tmux)
   augroup ResetCursorShape
      au!
      "autocmd VimEnter * startinsert | stopinsert
      autocmd VimEnter * normal! :startinsert :stopinsert
      "autocmd VimEnter * :normal :startinsert :stopinsert
   augroup END

   " reset cursor when leaving tmux
   autocmd VimLeave * silent !echo -ne "\033Ptmux;\033\033[2 q\033\\"
   autocmd VimLeave * silent !echo -ne "\033Ptmux;\033\033]12;gray\007\033\\"
endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CursorLine Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomCursorLineSettings()
set cursorline          "Display Cursorlinea
autocmd InsertEnter * set nocul
autocmd InsertLeave * set cul
"https://stackoverflow.com/questions/6488683/how-to-change-the-cursor-between-normal-and-insert-modes-in-vim
highlight CursorLine ctermfg=none ctermbg=233 cterm=bold guifg=NONE guibg=#121212 gui=bold
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CursorLine Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomBackgroundSettings()
set t_ut=""		"Vim's "Background Color Erase (BCE)" option

endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Search Options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomSearchSettings()
set mousemodel=extend	" Shift-LeftClick a word to search forwards, or Shift-RightClick to search backwards in gvim
set ignorecase			" Innore case while searching
set smartcase			" If CAPS case sensitive, if SMALL case insensitive
set incsearch			" fallow as you type
set hlsearch			" Highlight search
"map * /\<<C-R>=expand('<cword>')<CR>\><CR>
"map # ?\<<C-R>=expand('<cword>')<CR>\><CR>
":set nowrapscan        " do not wrap around
":set wrapscan          " wrap around
":set wrapscan!         " toggle wrap around on/off
":set ws! ws?           " toggle and show value
"set fdo?				" chech "search" as option
"https://vim.fandom.com/wiki/Searching
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cursor
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomHighlightSettings()

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" QuickFix Window Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomQuickFixWindowSettings()
autocmd QuickFixCmdPre * let g:mybufname=bufname('%')
autocmd QuickFixCmdPost * botright copen 8 | exec bufwinnr(g:mybufname) . 'wincmd w'
autocmd QuickFixCmdPost * botright copen 8 | wincmd p
"https://vi.stackexchange.com/questions/16804/open-quickfix-window-without-focusing-it
autocmd FileType qf nnoremap <buffer> <CR> <CR><C-W>p
"https://stackoverflow.com/questions/21838975/vim-quickfix-avoid-buffer-change
hi QuickFixLine term=reverse guibg=Cyan
hi Search term=reverse ctermfg=0 ctermbg=222 guifg=#000000 guibg=#FFE792
highlight BlueLine guibg=Blue
autocmd BufReadPost quickfix match BlueLine /\%1l/
autocmd BufReadPost quickfix nnoremap <buffer> <CR> :execute 'match BlueLine /\%' . line('.') . 'l/'<CR><CR>

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomColorSettings()
" Color test: Save this file, then enter ':so %'
" Then enter one of following commands:
"   :VimColorTest    "(for console/terminal Vim)
"   :GvimColorTest   "(for GUI gvim)
function! VimColorTest(outfile, fgend, bgend)
  let result = []
  for fg in range(a:fgend)
    for bg in range(a:bgend)
      let kw = printf('%-7s', printf('c_%d_%d', fg, bg))
      let h = printf('hi %s ctermfg=%d ctermbg=%d', kw, fg, bg)
      let s = printf('syn keyword %s %s', kw, kw)
      call add(result, printf('%-32s | %s', h, s))
    endfor
  endfor
  call writefile(result, a:outfile)
  execute 'edit '.a:outfile
  source %
endfunction
" Increase numbers in next line to see more colors.
command! VimColorTest call VimColorTest('vim-color-test.tmp', 12, 16)

function! GvimColorTest(outfile)
  let result = []
  for red in range(0, 255, 16)
    for green in range(0, 255, 16)
      for blue in range(0, 255, 16)
        let kw = printf('%-13s', printf('c_%d_%d_%d', red, green, blue))
        let fg = printf('#%02x%02x%02x', red, green, blue)
        let bg = '#fafafa'
        let h = printf('hi %s guifg=%s guibg=%s', kw, fg, bg)
        let s = printf('syn keyword %s %s', kw, kw)
        call add(result, printf('%s | %s', h, s))
      endfor
    endfor
  endfor
  call writefile(result, a:outfile)
  execute 'edit '.a:outfile
  source %
endfunction
command! GvimColorTest call GvimColorTest('gvim-color-test.tmp')
endfunction

function! VimCtermColorTest()
let num = 255
while num >= 0
    exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
    exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
    call append(0, 'ctermbg='.num.':....')
    let num = num - 1
endwhile
endfunction
command! VimCtermColorTest call VimCtermColorTest()
function SetCustomLnguageSettings()

if !has("gui_running")
    set t_Co=256
    set term=screen-256color
	set term=xterm-256color
endif

" fix cursor display in cygwin
if has("win32unix")
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
endif

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Vim keep window position when switching buffers
"https://stackoverflow.com/questions/4251533/vim-keep-window-position-when-switching-buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomBufferPositionSettings()
if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Indentation
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomIndentationSettings()
"Only do this part when compiled with support for autocommands.
if has("autocmd")
    " Use filetype detection and file-based automatic indenting.
    filetype plugin indent on

    " Use actual tab chars in Makefiles.
    autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif
" For everything else, use a tab width of 4 space chars.
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=4    " Indents will have a width of 4.
set softtabstop=4   " Sets the number of columns for a TAB.
"set expandtab       " Expand TABs to spaces.
set autoindent
set smartindent
"set nowrap
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mouse Mode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomMouseSettings()
set mouse=a
autocmd InsertEnter * set mouse=""
autocmd InsertLeave * set mouse=nv
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Show tab and Spaces
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomTabSpaceSettings()
"set list listchars=tab:❘⠀,trail:·,extends:»,precedes:«,nbsp:×
"https://vi.stackexchange.com/questions/422/displaying-tabs-as-characters
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Complete Option Settings
" As soon as you press feedkeys(. ,->) or write words this opens
" completion menu to select words. Use <TAB> <S-TAB> to select from menu
" Read: https://stackoverflow.com/questions/35837990/how-to-trigger-omnicomplete-auto-completion-on-keystrokes-in-insert-mode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" if completion menu closed, and two non-spaces typed, call autocomplete
let s:insert_count = 0
function! OpenCompletion()
    if string(v:char) =~ ' '
        let s:insert_count = 0
    else
        let s:insert_count += 1
    endif
    if !pumvisible() && s:insert_count >= 2
        silent! call feedkeys("\<C-n>", "n")
    endif
endfunction

function! TurnOnAutoComplete()
    augroup autocomplete
        autocmd!
        autocmd InsertLeave let s:insert_count = 0
        autocmd InsertCharPre * silent! call OpenCompletion()
    augroup END
endfunction

function! TurnOffAutoComplete()
    augroup autocomplete
        autocmd!
    augroup END
endfunction

function! ReplayMacroWithoutAutoComplete()
    call TurnOffAutoComplete()
    let reg = getcharstr()
    execute "normal! @".reg
    call TurnOnAutoComplete()
endfunction

function AutoCompleteOptions()
"set completeopt=menu,preview,longest		"Auto fill the longest common substring of all possible matches
"set completeopt=menu,preview				" Auto fill the first match
set completeopt+=menuone,noselect,noinsert	" don't insert text automatically
set pumheight=5 " keep the autocomplete suggestion menu small
set shortmess+=c " don't give ins-completion-menu messages
"You can use the following highlight groups:
"     Pmenu – normal item
"     PmenuSel – selected item
"     PmenuSbar – scrollbar
"     PmenuThumb – thumb of the scrollbar
"For example to set a grey background:
:highlight Pmenu ctermbg=grey guibg=gray
hi Pmenu ctermbg=green guibg=green
hi Pmenu ctermbg=blue guibg=blue
hi PmenuSel ctermbg=magenta guibg=magenta

call TurnOnAutoComplete()
" don't let the above mess with replaying macros
nnoremap <silent> @ :call ReplayMacroWithoutAutoComplete()<CR>
" use tab for navigating the autocomplete menu
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
inoremap <expr> <S> pumvisible() ? "\<C-e>" : "\<F1>"
" Improve completion popup menu
inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
"inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
"inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
"inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
"inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
endfunction

function SetCustomCompleteOptionSettings()
"autocmd FileType *  call AutoCompleteOptions()
autocmd FileType c,cpp,vim  call AutoCompleteOptions()
endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto Remove Trailing White Space
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomAutoRemoveTrailingwhiteSpaceSettings()
" Remove trailing white-space once the file is saved
try
	"Call the StripWhiteSpace plugin
	:StripWhitespace
catch
	"Call Default Vim Way
	au BufWritePre * silent g/\s\+$/s///
endtry
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto Remove Trailing White Space
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomWindowsLikeSaveFileSettings()
" Use CTRL-S for saving, also in Insert mode
noremap <C-S> :update!<CR>
vnoremap <C-S> <C-C>:update!<CR>
inoremap <C-S> <C-O>:update!<CR>
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Omni Completion Settings
" https://stackoverflow.com/questions/4925768/is-there-any-tip-or-trick-to-easily-select-the-first-word-of-gvims-omni-compl
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomOmniCompleteSettings()
" set omnicomplete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType cpp set omnifunc=ccomplete#Complete
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctags Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomCtagsSettings()
function! SetCtagsPath()
"set tags+=./tags
set tags+=./tags,tags;$HOME	"it tells Vim to look for a tags file in the directory
							" of the current file, in the current directory and up
							" and up until your $HOME (that's the meaning of the
							" semicolon), stopping on the first hit
							" set tags=./tags works with vim7.x but not with
							" vim8.0. In vim8.0 set tags=tags works.
set path+=.,..,../..
set cscopequickfix=s-,c-,d-,i-,t-,e-
endfunction
autocmd FileType c,cpp,python  call SetCtagsPath()

function SetTags()
    let curdir = getcwd()

    while !filereadable("tags") && getcwd() != "/"
        cd ..
    endwhile

    if filereadable("tags")
        execute "set tags=" . getcwd() . "/tags"
    endif

    execute "cd " . curdir
endfunction

"call SetTags()

"map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
"map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CscopeSettings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomCscopeSettings()
set nocompatible
"cscope file-searching alternative
function SetCscope()
    let curdir = getcwd()

    while !filereadable("cscope.out") && getcwd() != "/"
            cd ..
                endwhile

    if filereadable("cscope.out")
            execute "cs add " . getcwd() . "/cscope.out"
                endif

    execute "cd " . curdir
endfunction

"call SetCscope()

function s:FindFile(file)
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
    let $CSCOPE_DIR=s:FindFile("cscope.out")
    let $CSCOPE_DB=$CSCOPE_DIR."/cscope.out"
    if filereadable($CSCOPE_DB)
        cscope add $CSCOPE_DB $CSCOPE_DIR
    endif

    command -nargs=0 CCscope !cscope -ub -R &
endif
"highlight GtagsGroup  cterm=bold  ctermbg=103 ctermfg=255
"highlight GtagsHeader cterm=bold  ctermbg=24 ctermfg=255
"highlight GtagsProgressFile cterm=bold  ctermbg=none ctermbg=230
endfunction


"------------------------------------------------------------------------
"------------------------------------------------------------------------
" Misclenious
"------------------------------------------------------------------------
"------------------------------------------------------------------------

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"---------------: Remember the Cursor :---------------
"" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
"https://gist.github.com/jetpks/1317871
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set viminfo='10,\"100,:20,%,n~/.viminfo
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Copy Paste mode
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
silent! nunmap <F4>
set pastetoggle=<F4>
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif
  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"
  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
"https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
"https://github.com/ConradIrwin/vim-bracketed-paste
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
    " Better mouse support, see  :help 'ttymouse'
    set ttymouse=sgr

    " Enable true colors, see  :help xterm-true-color
    let &termguicolors = v:true
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

    " Enable bracketed paste mode, see  :help xterm-bracketed-paste
    let &t_BE = "\<Esc>[?2004h"
    let &t_BD = "\<Esc>[?2004l"
    let &t_PS = "\<Esc>[200~"
    let &t_PE = "\<Esc>[201~"

    " Enable focus event tracking, see  :help xterm-focus-event
    let &t_fe = "\<Esc>[?1004h"
    let &t_fd = "\<Esc>[?1004l"

    " Enable modified arrow keys, see  :help xterm-modifier-keys
    execute "silent! set <xUp>=\<Esc>[@;*A"
    execute "silent! set <xDown>=\<Esc>[@;*B"
    execute "silent! set <xRight>=\<Esc>[@;*C"
    execute "silent! set <xLeft>=\<Esc>[@;*D"
endif
"https://stackoverflow.com/questions/2514445/turning-off-auto-indent-when-pasting-text-into-vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomTestSettings()
" no file change pop up warning
autocmd FileChangedShell * echohl WarningMsg | echo "File changed shell." | echohl None
set diffexpr=MyDiff()

endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DIFF Options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

function GetAckGrep()
"https://vi.stackexchange.com/questions/17704/how-to-remove-character-returned-by-system
"https://vi.stackexchange.com/questions/19688/substituting-in-vimscript
  let l:names = system("ack-grep --nocolumn  msg")
  let l:name = substitute(l:name, ':', '\t', 'g')
  echon l:name
  call OpenTag("SEARCH", "", l:name )
  return l:name
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"------------------------------------------------------------------------
"------------------------------------------------------------------------
"              Plugin Settingd
"------------------------------------------------------------------------
"------------------------------------------------------------------------

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Airline Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomAirlinePluginSettings()
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alyt_sep = '|'
let g:airline#extensions#tabline#formatter = 'default'
"let g:airline_extensions = []
let g:airline_section_warning=''
let g:airline_detect_whitespace=0
let g:airline#extensions#whitespace#enabled = 0
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Mark.vim Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomMarkPluginSettings()
nmap <2-LeftMouse> <Plug>MarkSet
nmap <C-N> <Plug>MarkAllClear
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Mark.vim Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomClangCompletePluginSettings()
" provide path directly to the library file
let g:clang_library_path='/usr/lib/x86_64-linux-gnu/libclang-10.so.1'
let g:clang_complete_auto=1
let g:clang_complete_copen=0
autocmd FileType c set omnifunc=ClangComplete
autocmd FileType c set completefunc=ClangComplete
autocmd FileType cpp set omnifunc=ClangComplete
autocmd FileType cpp set completefunc=ClangComplete
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"tagstack.vim Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomTagStackPluginSettings()
let g:tagstack_key_map_enable = 1
let g:tagging_system = 2
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function SetCustomPluginSettings()
let g:show_spaces_that_precede_tabs=1
endfunction

call Main()
