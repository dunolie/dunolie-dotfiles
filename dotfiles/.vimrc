" ----------------------------------------------------------------------------
"         Author: Robbie -- dunolie (at) gmail (dot) com
"      File Name: vimrc ($HOME/.vimrc)
"        Created: Thu 26 Feb 2006 03:15:54 PM GMT
"  Last Modified: Fri 16 Jul 2010 23:31:49 pm BST
" ----------------------------------------------------------------------------
"       Comments: mainly used on mac OS X
"    Description:
" ----------------------------------------------------------------------------
" TODO ~ fix the colorscheme!! it does not want to load automatically >:s
" ----------------------------------------------------------------------------
"                              REFERENCES
" ----------------------------------------------------------------------------
" http://macresearch.org/vim-making-it-work-leopard
" http://phaseportrait.blogspot.com
" http://www.viemu.com/a-why-vi-vim.html
" http://tottinge.blogsome.com/use-vim-like-a-pro
" http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html
" http://www.macresearch.org/using_pbcoby_and_pbpaste_to_bridge_the_terminal_and_the_desktop
" http://www.rayninfo.co.uk/vimtips.html
"
"-----------------------------------------------------------------------
" terminal setup
"-----------------------------------------------------------------------
"This must be first, because it changes other options as a side effect.
set nocompatible
"-----------------------------------------------------------------------
colorscheme dunolie

"store lots of :cmdline history
set history=500

" turn of the startup message
set shortmess+=I

" set map leader character
let mapleader=","

" Highlight current line
set cursorline

"---------------------------------------------------------------------------
" Timestamps and modification dates
" --------------------------------------------------------------------------
" Exclude these
let g:timestamp_automask = "~/.vim/abbr"

"<!-- Timestamp: Thu 26/02/2004 05:49:33 PM gautam@math:timestamp.txt -->
augroup TimeStampHtml
	au filetype html let b:timestamp_regexp = '\v\C%(\<!-- Timestamp:\s{-1,})@<=.{-}%(\s*--\>)@='
	au filetype html let b:timestamp_rep = '%a %d/%m/%Y %r #u@#h:#f'
augroup END

""http://www.vim.org/scripts/script.php?script_id=923
let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$'

"---------------------------------------------------------------------------
" Colours
" --------------------------------------------------------------------------
"if &term =~# '^\(screen\|xterm\)$'
"    set t_Co=256
"endif

" This .vimrc file should be placed in your home directory
" The Terminal app supports (at least) 16 colors
" So you can have the eight dark colors and the eight light colors
" the plain colors, using these settings, are the same as the light ones
" NOTE: You will need to replace ^[ with a raw Escape character, which you
" can type by typing Ctrl-V and then (after releaseing Ctrl-V) the Escape key.
if has("terminfo")
	set t_Co=16
	set t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm
	set t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
else
	set t_Co=16
	set t_Sf=[3%dm
	set t_Sb=[4%dm
endif

"---------------------------------------------------------------------------
" Colorscheme
" --------------------------------------------------------------------------
"dont load csapprox if no gui support - silences an annoying warning
if !has("gui")
		let g:CSApprox_loaded = 1
		colorscheme dunolie
	else
	if has("gui_gnome")
		set term=gnome-256color
		colorscheme 256_ir_black
	endif
	if has("gui_mac") || has("gui_macvim")
		colorscheme 256_ir_black
		set guifont=Menlo:h13
	endif
		if has("gui_win32") || has("gui_win32s")
		set guifont=Consolas:h12
		colorscheme 256_ir_black
	endif
endif

"---------------------------------------------------------------------------
" Statusline
" --------------------------------------------------------------------------
" Setting colours via user groups for status line
" http://got-ravings.blogspot.com/2008/08/vim-pr0n-making-statuslines-that-own.html"
" define 3 custom highlight group

hi User1 ctermbg=darkgray ctermfg=lightred cterm=NONE guibg=NONE guifg=lightred gui=NONE
hi User2 ctermbg=darkgray  ctermfg=magenta cterm=NONE guibg=NONE   guifg=magenta gui=NONE
hi User3 ctermbg=darkgray ctermfg=lightgreen cterm=NONE guibg=NONE  guifg=lightgreen gui=NONE

" --------------------------------------------------------------------------

set statusline= " clear the statusline for when vimrc is reloaded
" http://lumberjaph.net/blog/index.php/2008/06/26/git-branch-everywhere/
set statusline+=%#error#
set statusline+=%{g:gitCurrentBranch}  "keep at start of statusline
set statusline+=%*

set statusline+=%y "filetype
set statusline+=%#search#
set statusline+=\ %.20F       "tail of the file name
" set statusline+=%1*  "switch to User1 highlight (lightred on darkgr
" set statusline+=%#modemsg#  "switch to User3 highlight (lightgreen on darkgray)
set statusline+=%*
set statusline+=\ [♺%{TimeOfLastMod()}]
set statusline+=%#search#
set statusline+=%m "modified flag
set statusline+=%*
set statusline+=%#warningmsg# "display a warning if fileformat isnt unix
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

" display a warning if file encoding isnt utf-8
"set statusline+=%1*  "switch to User1 highlight (lightred on darkgray)
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%h      "help file flag
set statusline+=%r      "read only flag
set statusline+=%*   "switch back to statusline highlight
"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%{StatuslineTrailingSpaceWarning()}
set statusline+=%*
set statusline+=%{StatuslineLongLineWarning()}
" Display syntax error warning
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" display a warning if &paste is set
set statusline+=%#search#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

"set statusline+=%#warningmsg#
"set statusline=%{'$'[!&list]}
"set statusline=%{'~'[&pm=='']}
"set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%.20{CurDir()}\
set statusline+=%#search#
set statusline+=%{StatuslineCurrentHighlight()} "current highlight
set statusline+=%*
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %*
set statusline+=%#search#
set statusline+=%P    "percent through file
set statusline+=%*
set laststatus=2
"----------------------------------------------------------------------
"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
	if !exists("b:statusline_trailing_space_warning")
		if search('\s\+$', 'nw') != 0
			let b:statusline_trailing_space_warning = '[ws]'
		else
			let b:statusline_trailing_space_warning = ''
		endif
	endif
	return b:statusline_trailing_space_warning
endfunction

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
		let name = synIDattr(synID(line('.'),col('.'),1),'name')
		if name == ''
		return ''
	else
	return '[' . name . ']'
	endif
endfunction

"recalculate the RDtab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
	if !exists("b:statusline_tab_warning")
		let tabs = search('^\t', 'nw') != 0
		let spaces = search('^ ', 'nw') != 0
	if tabs && spaces
		let b:statusline_tab_warning =  '[m-ind!]'
	elseif (spaces && !&et) || (tabs && &et)
		let b:statusline_tab_warning = '[&et]'
	else
		let b:statusline_tab_warning = ''
	endif
	endif
		return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
if !exists("b:statusline_long_line_warning")
let long_line_lens = s:LongLines()

if len(long_line_lens) > 0
let b:statusline_long_line_warning = "[" .
\ '#' . len(long_line_lens) . "," .
\ 'm' . s:Median(long_line_lens) . "," .
\ '$' . max(long_line_lens) . "]"
else
let b:statusline_long_line_warning = ""
endif
endif
return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
let threshold = (&tw ? &tw : 80)
let spaces = repeat(" ", &ts)

let long_line_lens = []

let i = 1
while i <= line("$")
let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
if len > threshold
call add(long_line_lens, len)
endif
let i += 1
endwhile

return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
		let nums = sort(a:nums)
		let l = len(nums)
		if l % 2 == 1
				let i = (l-1) / 2
				return nums[i]
		else
				return (nums[l/2] + nums[(l/2)-1]) / 2
		endif
endfunction

function! TimeOfLastMod()
	return strftime("%d/%m/%y", getftime(bufname("%")))
endfunction

function! CurDir()
	let curdir = substitute(getcwd(), '/Users/robbie/', "~/", "g")
	return curdir
endfunction
"-----------------------------------------------------------------------
" Git Settings
"-----------------------------------------------------------------------

autocmd BufEnter * :call CurrentGitBranch()

let g:gitCurrentBranch = ''
function! CurrentGitBranch()
		let cwd = getcwd()
		cd %:p:h
		let branch = matchlist(system('/opt/local/bin/git  branch -a --no-color'), '\v\* (\w*)\r?\n')
		execute 'cd ' . cwd
	if (len(branch))
		let g:gitCurrentBranch = 'git:' . branch[1] . ''
	else
		let g:gitCurrentBranch = ''
	endif
	return g:gitCurrentBranch
endfunction

"-----------------------------------------------------------------------
" Mouse settings
"-----------------------------------------------------------------------
"
" for mouse use, hehehe (mouseterm) http://bitheap.org/mouseterm/
if has("mouse")
	set mousemodel=extend " Enable mouse support
	set selectmode=mouse
	set mouse=a
endif

" improve Vim copy for OSX terminal
if has('gui_running')
	set mousefocus          " Mouse can control splits
endif

"mouse control under screen
"if $TERM =~ '^screen' && exists("+ttymouse") && &ttymouse == ''
"	set ttymouse=xterm
"endif

" ,p and shift-insert will paste the X buffer, even on the command line
"nmap <LocalLeader>p i<S-MiddleMouse><ESC>
"imap <S-Insert> <S-MiddleMouse>
"cmap <S-Insert> <S-MiddleMouse>

" this makes the mouse paste a block of text without formatting it
" (good for code)
"map <MouseMiddle> <esc>"*p
"
"-----------------------------------------------------------------------

"-----------------------------------------------------------------------
"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:•,nbsp:•

" If  trailing spaces, tabs: show them.
" if `set list' tab is shown as >-----
" if `set list' a trailing space is shown as a colon.
"set nolist
"set lcs=tab:>-
"set lcs+=trail:.
" nmap <silent> <leader>s :set nolist!<CR>
"-----------------------------------------------------------------------
" Window's and Buffers
" Switch to alternate file
map <C-Tab> :bnext<cr>
map <C-S-Tab> :bprevious<cr>

" Map ctrl-movement keys to window switching
map <C-k> <C-w><Up>
map <C-j> <C-w><Down>
map <C-l> <C-w><Right>
map <C-h> <C-w><Left>
"-----------------------------------------------------------------------

set iskeyword+=_,$,@,%,#,-,:      " none of these should be
"
map <LocalLeader>ce :edit ~/.vimrc<cr>
" quickly edit this file
map <LocalLeader>cs :source ~/.vimrc<cr>
"quickly source this file

" Move to next buffer
map <LocalLeader>bn :bn<cr>
" Move to previous buffer
map <LocalLeader>bp :bp<cr>
" List open buffers
map <LocalLeader>bb :ls<cr>

" Y yanks from cursor to $
map Y y$
" toggle list mode
nmap <LocalLeader>tl :set list!<cr>
" toggle paste mode
nmap <LocalLeader>pp :set paste!<cr>
" change directory to that of current file
nmap <LocalLeader>cd :cd%:p:h<cr>
" change local directory to that of current file
nmap <LocalLeader>lcd :lcd%:p:h<cr>

" word swapping
nmap <silent> gw "_yiw:s/\(\%#\w\+\)\(\W\+\)\(\w\+\)/\3\2\1/<cr><c-o><c-l>
" char swapping
nmap <silent> gc xph

" auto load extensions for different file types
if has('autocmd')
filetype plugin indent on
syntax on
" jump to last line edited in a given file (based on .viminfo)
"autocmd BufReadPost *
"       \ if !&diff && line("'\"") > 0 && line("'\"") <= line("$") |
"       \       exe "normal g`\"" |
"       \ endif
autocmd BufReadPost *
\ if line("'\"") > 0|
\       if line("'\"") <= line("$")|
\               exe("norm '\"")|
\       else|
\               exe "norm $"|
\       endif|
\ endif

" auto complete brackets
"imap { {}<left>
"imap ( ()<left>
"imap [ []<left>

" improve legibility
au BufRead quickfix setlocal nobuflisted wrap number

" configure various extenssions
let git_diff_spawn_mode=2

" improved formatting for markdown
" http://plasticboy.com/markdown-vim-mode/
autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:>
autocmd BufRead ~/.blog/entries/*  set ai formatoptions=tcroqn2 comments=n:>
endif
augroup mkd
autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:>
augroup END
"-----------------------------------------------------------------------
set path=$PWD/**

" Extra terminal things
if (&term =~ "xterm") && (&termencoding == "")
	set termencoding=utf-8
endif

if &term =~ "xterm"
" use xterm titles
if has('title')
	set title
	set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
endif

" ---------------------------------------------------------------------------
"  Set title in screen sessions
" ---------------------------------------------------------------------------
" http://vim.wikia.com/wiki/Automatically_set_screen_title
""set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

" change cursor colour depending upon mode
if exists('&t_SI')
		let &t_SI = "\<Esc>]12;lightgoldenrod\x7"
		let &t_EI = "\<Esc>]12;grey80\x7"
	endif
endif

" awesome, inserts new line without going into insert mode
map <S-Enter> O<ESC>
map <Enter> o<ESC>
set fo-=r " do not insert a comment leader after an enter, (no work, fix!!)

" ----------------------------------------------------------------------------
"                       Find whitespace and &et
" ----------------------------------------------------------------------------

function! SeekIndentWarningOccurrence()
	if (!&et)
		/^
	elseif (&et)
		/^\t
	endif
	exe "normal 0"
endfunction

function! SeekTrailingWhiteSpace()
let [nws_line, nws_col] = searchpos('\s\+$', 'nw')
if ( nws_line != 0 )
exe "normal ".nws_line."G"
" This would be nicer, but | doesn't seem to collapse \t in to 1 col?
" exe "normal ".nws_col."|"
" so i'll do this instead :( Might be a better way
exe "normal 0"
exe "normal ".(nws_col-1)."l"
endif
endfunction

" ----------------------------------------------------------------------------
"                           SYSTEM & RUN-TIME-PATHS
" ----------------------------------------------------------------------------

" http://mix.dk/blog/viewEntry/162 --  linux, mac, windows
fun! MySys()
return "mac"
endfun

set bs=2 " backspacing over everything in insert mode

"load ftplugins and indent files
filetype plugin on
filetype indent on
set ai " Auto indenting

" we like security/
set nomodeline

" minimum number of lines to keep above/below the cursor/
set scrolloff=2

" ----------------------------------------------------------------------------
"                              Clipboard Management
" ----------------------------------------------------------------------------

"Make sure paste mode is on before pasting
function! SmartPaste()
	set paste
	normal! p`[=`]
	set nopaste
endfunction
command! -bar            SmartPaste   :call SmartPaste()

" ----------------------------------------------------------------------------
"                                SYNTAX
" ----------------------------------------------------------------------------

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
		syntax on
		set incsearch   "find the next match as we type the search
		set hlsearch
	endif
" commented as i have the above setting for syntax as per terminal color options
"syntax on
" Colo(u)red or not colo(u)red
" If you want color you should set this to true
		let color = "true"
		if has("syntax")
		if color == "true"
" This will switch colors ON (syntax highlighting)
		so ${VIMRUNTIME}/syntax/syntax.vim
	else
" this switches colors OFF
		syntax off
		set t_Co=0
	endif
endif

" for ctrl-P and ctrl-N completion, get things from syntax file
autocmd BufEnter * exec('setlocal complete+=k$VIMRUNTIME/syntax/'.&ft.'.vim')

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

" ----------------------------------------------------------------------------
"                                  VARIOUS
" ----------------------------------------------------------------------------

" Syntax highlighting for subtitle files (srt/sub)
au BufNewFile,BufRead *.srt setf srt
au BufNewFile,BufRead *.sub setf sub

"
let g:tex_flavor='LaTeX'
" When editing a file, always jump to the last cursor position

" http://amix.dk/blog/viewEntry/162
autocmd BufReadPost *
\ if ! exists("g:leave_my_cursor_position_alone") |
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\ exe "normal g'\"" |
\ endif |
\ endif

" Always show the menu, insert longest match
set completeopt=menuone,longest

"auto-detect the file type
filetype plugin indent on

map ¬Ω $
imap ¬Ω $
vmap ¬Ω $
cmap ¬Ω $

" ----------------------------------------------------------------------------
"                           VARIOUS GENERAL SETTINGS
" ----------------------------------------------------------------------------

" for the (auto)indent modes.
set shiftwidth=8

" tab is 4 spaces in size.
set tabstop=4

" interpret modeline in files.
set modeline

" Don't show line numbers (toggled with F5)
set nonu

" incremental search.
set incsearch

" for matching (), {}, [].
set showmatch

if has('cmdline_info')
	" show the cursor position.
	set ruler
	" a ruler on steroids/
	set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
	set showcmd
	" show partial commands in status line and selected characters lines in
	" visual mode/
	set showcmd
endif

"---------------------------------------------------
"indenting for code

" noautoindent.
set noai

" smart auto indenting
set smartindent

" no C style indent
set nocindent

" no wrap lines at blank.
set nolinebreak

" changed from 78
" no wordwrap.
set textwidth=0

" behaviour of backspace keys in insert mode.
"set backspace=2
set backspace=indent,eol,start

" syntax highlighting (use dark if the background is dark).
set background=dark

" do not ignore case while searching.
set noignorecase

" show which mode we're in (insert, replace, etc)
set showmode

" do not keep a search highlighted.
"set nohlsearch  "OFF as i have it set in my syntax settings

" for in search patterns. I have no clue what it does.
set magic

" keep cursor in the present column with page commands.
set nostartofline

" <>hl to move to another line if at the start or end of a line.
set whichwrap=<,>,h,l

" what's kept in the file .viminfo.
set viminfo=%,'50
set viminfo+=\"100,:100
set viminfo+=n~/.viminfo

" Map my tabs
map <C-t><up> :tabr<cr> map <C-t><down> :tabl<cr> map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

"tabs are not expanded to spaces (see retab command as well).
set noexpandtab

" switch bell off.
set vb t_vb=

" set the print options.
set printoptions=header:0

" suffixes that get lower priority when doing tab completion for file names.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" Speed optimizations
set lz
set ttyfast

" ----------------------------------------------------------------------------
"  Mappings
" ----------------------------------------------------------------------------
" FKEYS Mapping
"  F01 = NerdTree - toggle
"  F02 = Taglist - toggle
"  F03 = Search history - toggle
"  F04 = add a comment line
"  F05 = Line numbers, on/off
"  F06 = Uncomment lines - Visual mode
"  F07 = Paste mode - ON
"  F08 = Paste mode - OFF
"  F09 = Syntax on/off
"  F10 = Comment the selected lines in visual mode
"  F11 = Unused (OSX)
"  F12 = Unused (OSX)
"  F13 = rot-13 (encrypt) file
"  F14 = Auto format paragraph
"  F15 = Help
" ----------------------------------------------------------------------------
"map <F9> :source ~/.vim/text_dead.vim<CR>      " Dead key functionality.
"noremap <F9> :call Switch_DeadKeys()<CR>

" map <F1> to toggle NERDTree window
nmap <silent> <F1> :NERDTreeToggle<CR>

" Toggle the taglist
map <silent> <F2> :TlistToggle<CR>

" Toggle highligted search results
map <silent> <F3> :set invhlsearch<CR>

" Toggle line numbers
" map <silent> <F4> :set invnumber<CR>

" syntax on/off
map <F6> :if exists("syntax_on") <Bar>
	\   syntax off <Bar>
\ else <Bar>
	\   syntax enable <Bar>
\ endif <CR>

" numbers on/off
map <silent> <F5> :if &number <Bar>
    \set nonumber <Bar>
\else <Bar>
    \set number <Bar>
\endif<cr>

" Map F10 to comment the selected lines in visual mode (// style comments)
vmap <F10> :s/^/\/\/\ /g <CR> :noh <CR>

" Map F6 to uncomment the selected lines in visual mode
vmap <F6> :s/^\/\/\ //g <CR> :noh <CR>

" Toggle paste
map <F7> :set paste<CR>
map <F8> :set nopaste<CR>

"dictionary
map <F9> :exe ":!dict ".expand("<cword>")
" Switch  rot-13 on/off (encrypt)
""map <F13> ggVGg?

" Auto format paragraph
map <F14> gqap

" ----------------------------------------------------------------------------

" Update vim plugins automatically
" http://jetpackweb.com/blog/2010/01/12/how-to-keep-your-vim-plugins-up-to-date/
""let g:GetLatestVimScripts_allowautoinstall=1
""set runtimepath+=~/.vim/vim-addon-manager
""call vam#ActivateAddons([Nerdtree ctags])
"
"put thiss line first in ~/.vimrc
        set nocompatible | filetype indent plugin on | syn on

        fun! EnsureVamIsOnDisk(plugin_root_dir)
          " windows users may want to use http://mawercer.de/~marc/vam/index.php
          " to fetch VAM, VAM-known-repositories and the listed plugins
          " without having to install curl, 7-zip and git tools first
          " -> BUG [4] (git-less installation)
          let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
          if isdirectory(vam_autoload_dir)
            return 1
          else
            if 1 == confirm("Clone VAM into ".a:plugin_root_dir."?","&Y\n&N")
              " I'm sorry having to add this reminder. Eventually it'll pay off.
              call confirm("Remind yourself that most plugins ship with ".
                          \"documentation (README*, doc/*.txt). It is your ".
                          \"first source of knowledge. If you can't find ".
                          \"the info you're looking for in reasonable ".
                          \"time ask maintainers to improve documentation")
              call mkdir(a:plugin_root_dir, 'p')
              execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
                          \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
              " VAM runs helptags automatically when you install or update 
              " plugins
              exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
            endif
            return isdirectory(vam_autoload_dir)
          endif
        endfun

        fun! SetupVAM()
          " Set advanced options like this:
          " let g:vim_addon_manager = {}
          " let g:vim_addon_manager.key = value
          "     Pipe all output into a buffer which gets written to disk
          " let g:vim_addon_manager.log_to_buf =1

          " Example: drop git sources unless git is in PATH. Same plugins can
          " be installed from www.vim.org. Lookup MergeSources to get more control
          " let g:vim_addon_manager.drop_git_sources = !executable('git')
          " let g:vim_addon_manager.debug_activation = 1

          " VAM install location:
          let c = get(g:, 'vim_addon_manager', {})
          let g:vim_addon_manager = c
          let c.plugin_root_dir = expand('$HOME/.vim/vim-addons')
          if !EnsureVamIsOnDisk(c.plugin_root_dir)
            echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
            return
          endif
          let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'

          " Tell VAM which plugins to fetch & load:
          call vam#ActivateAddons([], {'auto_install' : 0})
          " sample: call vam#ActivateAddons(['pluginA','pluginB', ...], {'auto_install' : 0})

          " Addons are put into plugin_root_dir/plugin-name directory
          " unless those directories exist. Then they are activated.
          " Activating means adding addon dirs to rtp and do some additional
          " magic

          " How to find addon names?
          " - look up source from pool
          " - (<c-x><c-p> complete plugin names):
          " You can use name rewritings to point to sources:
          "    ..ActivateAddons(["github:foo", .. => github://foo/vim-addon-foo
          "    ..ActivateAddons(["github:user/repo", .. => github://user/repo
          " Also see section "2.2. names of addons and addon sources" in VAM's documentation
        endfun
        call SetupVAM()
        " experimental [E1]: load plugins lazily depending on filetype, See
        " NOTES
        " experimental [E2]: run after gui has been started (gvim) [3]
        " option1:  au VimEnter * call SetupVAM()
        " option2:  au GUIEnter * call SetupVAM()
        " See BUGS sections below [*]
        " Vim 7.0 users see BUGS section [3]

" Use SQL Server syntax file for .sql files
let g:sql_type_default = "sqlserver"
" Functions for cleaning up tabs and spaces
function! RemoveTrailingSpaces()
	%s/\s\+$//e
	%s/
//ge
endfunction

" Move cursor over visible lines:
noremap <Up> gk
noremap <Down> gj
inoremap <Up> <C-O>gk
inoremap <Down> <C-O>gj

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

" Undo in Insert mode (CTRL+Z)
map <c-z> <c-o>u)

" make search results appear in the middle of the screen:
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" fix my <Backspace> key (in Mac OS X Terminal)
"set t_kb=fixdel

" ---------------------------------------------------------------------------
"                          Ctags
"
" ---------------------------------------------------------------------------
"
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Process_File_Always = 1
let Tlist_Show_Menu = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 25
let Tlist_Inc_WinWidth = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Auto_Open = 0
let Tlist_Use_SingleClick = 1
let Tlist_Compact_Format = 1
let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'

map <leader>l :TlistToggle<CR>

" ---------------------------------------------------------------------------
"                          FuzzyFinder
" ---------------------------------------------------------------------------
"
"map to fuzzy finder text mate style
nnoremap <c-f> :FuzzyFinderTextMate<CR>
"map <leader>t :FuzzyFinderTextMate<CR>
"map <leader>b :FuzzyFinderBuffer<CR>
" FuzzyFinder
nnoremap <Leader>fb :FuzzyFinderBuffer<CR>
nnoremap <Leader>ff :FuzzyFinderFile<CR>

map <leader>d :execgnore = "*.log"
let g:fuzzy_matching_limit = 70
let g:fuzzy_ceiling=20000 " file count limit to search

" Add what to ignore in the fuzzy search
let g:fuzzy_ignore = "*.png;*.PNG;*.JPG;*.jpg;*.GIF;*.gif"
let g:fuzzy_ignore = "*.ogg;*.OGG;*.ogv;*.OGV;*.mkv;*.MKV"
let g:fuzzy_ignore = "*.mp3;*.mp3;*.mp4;*.MP4;*.avi;*.AVI;*.wma;*.WMA;*.wmv;*.WMV"
let g:fuzzy_ignore = "*.flv;*.FLV;*.mov;*.MOV;*.pdf;*.PDF"
let g:fuzzy_ignore = "*.zip;*.ZIP;*.tar;*.7z;*.gz;*.bz2"
let g:fuzzy_ignore = "*.bak;*.dmg;*.flac;*.part;*.torrent"

map <leader>R :RunSpecs<CR>
map <leader>f :Ack

" ---------------------------------------------------------------------------
"                          NERDTree
" ---------------------------------------------------------------------------
" Increase window size to 25 columns
let NERDTreeWinSize=25

" map <F7> to toggle NERDTree window
" nmap <silent> <F7> :NERDTreeToggle<CR>

if has("gui_running")
		if &diff
		set columns=150
	endif
endif

"" Plugins
" NERD_commenter
let NERDSpaceDelims=1
let NERDShutUp=1
nnoremap <Leader>nt :NERDTreeToggle<CR>

" ---------------------------------------------------------------------------
"                          NerdComment
" ---------------------------------------------------------------------------

let  NERDCreateDefaultMappings=0
let NERDSpaceDelims=1
map <Leader>/ NERDCommenterToggle
map <Leader>cal NERDCommenterAlignLeft
map <Leader>cuc NERDCommenterUncomment

" ---------------------------------------------------------------------------
"                          Various
" ---------------------------------------------------------------------------
" http://svn.codecheck.in/dotfiles/vim/debility/.vimrc

" Use menu to show command-line completion (in 'full' case)
set wildmenu

" Set command-line completion mode:
"   - on first <Tab>, when more than one match, list all matches and complete
"     the longest common  string
"   - on second <Tab>, complete the next full match and show menu
set wildmode=list:longest,full

" Go back to the position the cursor was on the last time this file was edited
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")|execute("normal `\"")|endif

" Write contents of the file, if it has been modified, on buffer exit
set autowrite

" ignore these file types when opening/
set wildignore=*.pyc,*.o,*.obj,*.swp

" ToggleComment - http://www.vim.org/scripts/script.php?script_id=955
map ,# :call CommentLineToEnd(‚Äô# ‚Äò)+
map ,* :call CommentLinePincer('/* ', ' */')<CR>+
map ," :call CommentLineToEnd('"')<CR>+
" ---------------------------------------------------------------------------
"                          SCREENSHOTS
" ---------------------------------------------------------------------------
"  Sreenshot to html without icon and credits
"  http://www.vim.org/scripts/script.php?script_id=1552
let ScreenShot = {'Icon':0, 'Credits':0, 'force_background':'#FFFFFF'}

" ----------------------------------------------------------------------------
"                           MUTT & CVS
" ----------------------------------------------------------------------------

" for mutt
autocmd BufRead mutt*[0-9] set tw=72
autocmd BufRead mutt*[0-9] set formatoptions=tcqn
" set up syntax highlighting for my e-mail
au BufRead,BufNewFile .followup,.article,.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt* :set ft=mail

" for cvs commit logs
autocmd BufRead cvs*[a-zA-Z0-9] set tw=64
autocmd BufRead cvs*[a-zA-Z0-9] set formatoptions=tqn

" --------------------------------------------------------------------------
"                         Make executable
" ---------------------------------------------------------------------------
" automatically give executable permissions if file begins with #! and contains
" '/bin/' in the path
"
au BufWritePost * if getline(1) =~ "^#!" | if getline(1) =~ "/bin/" | silent !chmod a+x <afile> | endif | endif

" --------------------------------------------------------------------------
"                            SPELLING
" ---------------------------------------------------------------------------

" Spell Checking in VIM from - http://hacktux.com/
" Enable
set nospell

" Enable Spellfile
set spelllang=en_gb
" zg to add word to word list
" zw to reverse
" zug to remove word from word list
" z= to get list of possibilities
set spellfile=~/.vim/spellfile.add

" Set Colours For Spelling #moved to my default theme
"highlight clear SpellBad
"highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
"highlight SpellBad term=underline ctermfg=1 term=underline cterm=underline
"highlight clear SpellCap
"highlight SpellCap term=underline cterm=underline
"highlight SpellRare term=underline cterm=underline
"highlight clear SpellLocal
"highlight SpellLocal term=underline cterm=underline

map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

" Alternative Spelling options
"set spelllang=en
"set spellfile=~/.vim/en.utf-8.spl.add
let loaded_spellfile_plugin = 1

"-----------------------------------------------------------------------
" completion
"-----------------------------------------------------------------------
set dictionary=/usr/share/dict/words

"-----------------------------------------------------------------------
" align plugin helpers
"-----------------------------------------------------------------------

vmap <silent> <Leader>i= <ESC>:AlignPush<CR>:AlignCtrl lp1P1<CR>:'<,'>Align =<CR>:AlignPop<CR>
vmap <silent> <Leader>i, <ESC>:AlignPush<CR>:AlignCtrl lp0P1<CR>:'<,'>Align ,<CR>:AlignPop<CR>
vmap <silent> <Leader>i( <ESC>:AlignPush<CR>:AlignCtrl lp0P0<CR>:'<,'>Align (<CR>:AlignPop<CR>

"-----------------------------------------------------------------------
" Buffer Selection
"-----------------------------------------------------------------------
" http://djcraven5.blogspot.com/2006/10/faster-buffer-switches-in-vim_21.html
function! BufSel(pattern)
	let buflist = []
	let bufcount = bufnr("$")
	let currbufnr = 1
	while currbufnr <= bufcount
			if(buflisted(currbufnr))
					let currbufname = bufname(currbufnr)
					if (exists("g:BufSel_Case_Sensitive") == 0 || g:BufSel_Case_Sensitive == 0)
						let curmatch = tolower(currbufname)
						let patmatch = tolower(a:pattern)
				else
							let curmatch = currbufname
							let patmatch = a:pattern
					endif
					if(match(curmatch, patmatch) > -1)
							call add(buflist, currbufnr)
					endif
			endif
			let currbufnr = currbufnr + 1
	endwhile
	if(len(buflist) > 1)
			for bufnum in buflist
					echo bufnum . ":      ". bufname(bufnum)
			endfor
			let desiredbufnr = input("Enter buffer number: ")
			if(strlen(desiredbufnr) != 0)
					exe ":bu ". desiredbufnr
			endif
	elseif (len(buflist) == 1)
			exe ":bu " . get(buflist,0)
	else
			echo "No matching buffers"
	endif
endfunction
command! -nargs=1 -complete=buffer Bs :call BufSel("<args>")
cabbr b Bs

" ----------------------------------------------------------------------------
"                              ABBREVIATIONS
" ----------------------------------------------------------------------------

" Tip Taken from http://www.jnrowe.ukfsn.org/articles/configs/vim.html
"
if filereadable(expand("~/.vim/abbr"))
	source ~/.vim/abbr
endif

" ----------------------------------------------------------------------------
"                              Search
" ----------------------------------------------------------------------------

"Ignore case when searching
set ignorecase
set incsearch

" ----------------------------------------------------------------------------
" Visual
" ----------------------------------------------------------------------------
" From an idea by Michael Naumann
function! VisualSearch(direction) range
		let l:saved_reg = @"
		execute "normal! vgvy"
		let l:pattern = escape(@", '\\/.*$^~[]')
		let l:pattern = substitute(l:pattern, "\n$", "", "")
	if a:direction == 'b'
		execute "normal ?" . l:pattern . "^M"
	else
		execute "normal /" . l:pattern . "^M"
endif
		let @/ = l:pattern
		let @" = l:saved_reg
endfunction

"Basically you press * or # to search for the current selection !! Really useful
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

" ----------------------------------------------------------------------------
" Directory Settings
" ----------------------------------------------------------------------------

"Switch to current dir
map <leader>cd :cd %:p:h<cr>

" ----------------------------------------------------------------------------
" Files and backups
" ----------------------------------------------------------------------------
"
"Turn backup off
set nobackup
set nowb
set noswapfile

" ----------------------------------------------------------------------------
" Folding
" ----------------------------------------------------------------------------
set nofoldenable        "don't fold by default

"Enable folding, I find it very useful
""set enable folds
""if has("folding")
""	set foldenable
"	set foldmethod=indent   "fold based on indent
""	set foldnestmax=3       "deepest fold is 3 levels
""endif

" ----------------------------------------------------------------------------
" MISC
" ----------------------------------------------------------------------------
"Remove the Windows ^M
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Paste toggle - when pasting something in, don't indent.
" set pastetoggle=<F3>

"Super paste
inoremap <C-v> <esc>:set paste<cr>mui<C-R>+<esc>mv'uV'v=:set nopaste<cr>
" ----------------------------------------------------------------------------
" Paragraphs (HTML)
" ----------------------------------------------------------------------------
"map a shortcut to start a new html paragraph
map \p i<p></p><Esc>hhhi

" ----------------------------------------------------------------------------
" TOHtml
" ----------------------------------------------------------------------------

"" Configure HTML output with :TOhtml
"" let html_number_lines=1
let html_use_css=1
let html_use_xhtml=1
let html_dynamic_folds = 1

"A function that inserts links & anchors on a TOhtml export.
" Notice:  -- Syntax used is: Link, Anchor
function! SmartTOHtml()
		TOhtml
	try
		%s/&quot;\s\+\*&gt; \(.\+\)</" <a href="#\1" style="color: cyan">\1<\/a></g
		%s/&quot;\(-\|\s\)\+\*&gt; \(.\+\)</" \&nbsp;\&nbsp; <a href="#\2" style="color: cyan;">\2<\/a></g
		%s/&quot;\s\+=&gt; \(.\+\)</" <a name="\1" style="color: #fff">\1<\/a></g
	catch
	endtry
		exe ":write!"
		exe ":bd"
endfunction

" ----------------------------------------------------------------------------
" Mini/BufEpxplorer
" ----------------------------------------------------------------------------
map <tab> :tabnext<cr>
map <S-tab> :tabprevious<cr>
" minibufexplorer
" ctrl-[hjkl] moves between windows
let g:miniBufExplMapWindowNavVim = 1
" ctrl-tab and ctrl-shift-tab switch between buffers
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplModSelTarget = 1

" bufexplorer settings (launch with \be or \])
nmap <silent> <unique> <leader>] <Esc>:BufExplorer<CR>

" Tab navigation
nmap <silent> <C-t> :tabnew<CR>
nmap <silent> <C-j> gT
nmap <silent> <C-k> gt
nmap <silent> <C-h> :tabfirst<CR>
nmap <silent> <C-l> :tablast<CR>
nmap <silent> <leader>ta <Esc>:tab ball<CR>

" Split window navigation
nmap <c-down> <c-w>w
nmap <c-up> <c-w>W
nmap <c-left> <c-w>h
nmap <c-right> <c-w>l
" ----------------------------------------------------------------------------
" Task list - http://www.vim.org/scripts/script.php?script_id=2607
" ----------------------------------------------------------------------------
""map T :TaskList<CR>
"map P :TlistToggle<CR>
" ----------------------------------------------------------------------------

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
		if &filetype !~ 'commit\c'
		if line("'\"") > 0 && line("'\"") <= line("$")
		exe "normal! g`\""
		normal! zz
	endif
	end
endfunction

"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
		let targetWidth = a:width != '' ? a:width : 79
		if targetWidth > 0
		exec 'match Todo /\%>' . (targetWidth) . 'v/'
	else
		echomsg "Usage: HighlightLongLines [natural number]"
	endif
endfunction

" ----------------------------------------------------------------------------
" Snippets
" ----------------------------------------------------------------------------
"snipmate setup
source ~/.vim/snippets/support_functions.vim
autocmd vimenter * call s:SetupSnippets()
function! s:SetupSnippets()
		"if we're in a rails env then read in the rails snippets
		if filereadable("./config/environment.rb")
		call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
		call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
	endif
		call ExtractSnips("~/.vim/snippets/html", "eruby")
		call ExtractSnips("~/.vim/snippets/html", "xhtml")
		call ExtractSnips("~/.vim/snippets/html", "php")
endfunction
autocmd vimenter * call ExtractSnips("~/.vim/snippets/html", "eruby")
autocmd vimenter * call ExtractSnips("~/.vim/snippets/html", "php")

"visual search mappings
function! s:VSetSearch()
		let temp = @@
		norm! gvy
		let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
		let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" ----------------------------------------------------------------------------
" gvim
" ----------------------------------------------------------------------------

if has('gui_running')
		set guioptions-=T          ""/" remove the toolbar/
		set lines=999
	if has("mac")
		set guifont=Menlo:h14
	elseif has("unix")
		set guifont=Bitstream\ Vera\ Sans\ Mono\ 14
	elseif has("win32") || has("win64")
		set guifont=Consolas:h14:cANSI
	endif
		set cursorline
endif

" smart tab completion
function! InsertTabWrapper(direction)
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<tab>"
	elseif "back" == a:direction
		return "\<c-p>"
	else
		return "\<c-n>"
	endif
endfunction

inoremap <tab> <c-r>= ("forw")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("back")<cr>

"edit json and make more readable - uses cpan JSON::XS - (mapleader ,jt)
map <leader>jt  <Esc>:%!json_xs -f json -t json-pretty<CR>

"" edit file as sudo
command! -bar -nargs=0 SudoW   :silent exe "write !sudo tee % >/dev/null" | silent edit!

"paste in vim without moving the cursor
noremap P P` [
" ---------------------------------------------------------------------------
"  Strip all trailing whitespace in file
" ---------------------------------------------------------------------------

function! StripWhitespace ()
	exec ':%s/ \+$//g'
endfunction
map ,s :call StripWhitespace ()<CR>

" ----------------------------------------------------------------------------
"                  File Types
" ----------------------------------------------------------------------------
au BufNewFile,BufRead *.yaml,*.yml    setf yaml
au FileType c,cpp,java          let b:comment_leader = '// '
au FileType c,cpp,slang         set cindent
au FileType css                 set smartindent
au FileType haskell,vhdl,ada    let b:comment_leader = '-- '
au FileType html                set formatoptions+=tl
au FileType html,css            set noexpandtab tabstop=2
au FileType human               set noautoindent nosmartindent formatoptions-=r textwidth=72
au FileType make                set noexpandtab shiftwidth=8
au FileType perl                set smartindent
au FileType sh,make,perl,python let b:comment_leader = '# '
au FileType tex                 let b:comment_leader = '% '
" ----------------------------------------------------------------------------
" ~/.vimrc ends here
" ----------------------------------------------------------------------------
