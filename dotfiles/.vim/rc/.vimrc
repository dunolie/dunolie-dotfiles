" ----------------------------------------------------------------------------
"                            Robbie's VIMRC 
" ----------------------------------------------------------------------------
"   .~.                                                  
"   /V\        Robbie -- dunolie@gmail.com                       
"  //&\\    Created on: Friday,07 March, 2008
" /((@))\   
"  ^`~'^
" Last Modified: Mon  5 May 07:47:13 2008 , by: Robbie Terris
" (dunolie@gmail.com)
"
" ----------------------------------------------------------------------------
"                          Snipps From 
" ----------------------------------------------------------------------------

" File:         ~/.vimrc
" Author: W.J.M. Brok wjmb@etpmod.phys.tue.nl
" Website: http://www.etpmod.phys.tue.nl
" Author: Amir Salihefendic 
" Website: http://www.amix.dk/vim/vimrc.html
"
" 
" ----------------------------------------------------------------------------
"                              REFERENCES
" ----------------------------------------------------------------------------
"                               VIMRC References
" http://macresearch.org/vim-making-it-work-leopard
" http://phaseportrait.blogspot.com/  - Vim-LaTeX, Vim 7.0, and the filetype plugin
" http://www.viemu.com/a-why-vi-vim.html
" http://tottinge.blogsome.com/use-vim-like-a-pro
" http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html::
" http://www.macresearch.org/using_pbcoby_and_pbpaste_to_bridge_the_terminal_and_the_desktop
" http://www.rayninfo.co.uk/vimtips.html
"

" ----------------------------------------------------------------------------
"                           SYSTEM & RUN-TIME-PATHS
" ----------------------------------------------------------------------------

" http://amix.dk/blog/viewEntry/162
" Can be: linux, mac, windows
fun! MySys()
  return "unix"
endfun

if has('mac')
    set runtimepath+=~/.vim/
    helptags ~/.vim/doc/
endif



" TROUBLESOME VIMRUNTIME :(

"set runtimepath=~/.vim
"set "runtimepath+=~/.vim/after,~/.vim/syntax,~/.vim/plugins,~/.vim/macros,,~/.vim/autoload,~/.vim/compiler,~/.vim/macros,~/.vim/spell,~/.vim"/syntax,~/.vim/doc,$VIMRUNTIME
" source ~/vim_local/vimrc
"set runtimepath=$VIMRUNTIME
" ----------------------------------------------------------------------------
"                                COLORS & GUI
" ----------------------------------------------------------------------------

" FAVORITE FONT - Bitstream Vera Sans Mono , 14pt 
" set guifont=Bitstream_Vera_Sans_Mono:h14:cDEFAULT
" set guifont=Bitstream\ Vera\ Sans\ Mono:14:cDEFAULT

set bs=2 " backspacing over everything in insert mode
filetype plugin on " use the file type plugins
set ai " Auto indenting


"The colour scheme we are using: NOT USING ATM
"colorscheme elflord
"colorscheme candy
colorscheme ir_black 
"full black blackground -badly formated
"colorscheme desert
"colorscheme zellner

" ----------------------------------------------------------------------------
"                                SYNTAX COLORS
" ----------------------------------------------------------------------------

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
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

" ----------------------------------------------------------------------------
"                                  VARIOUS
" ----------------------------------------------------------------------------

" Prevents Vim 7.0 from setting filetype to 'plaintex'
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

"auto-detect the filetype
filetype plugin indent on

map ½ $
imap ½ $
vmap ½ $
cmap ½ $


"MARKDOWN 
augroup mkd      
autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:>     
augroup END
" ----------------------------------------------------------------------------
"                           VARIOUS GENERAL SETTINGS
" ----------------------------------------------------------------------------

" We use vim, required to be able to use keypad keys and map missed escape 
" sequences
set nocompatible

" for the (auto)indent modes.
set shiftwidth=8

" tab is 8 spaces in size.
set tabstop=8

" interpret modeline in files.
set modeline

"Show line numbers
set nu

" incremental search.
set incsearch

" for matching (), {}, [].
set showmatch

" size of history.
set history=400

" show the cursor position.
set ruler

"---------------------------------------------------
"indenting for code

" noautoindent.
set noai

" smart auto indenting
" set smartindent

" no C style indent
set nocindent

" no wrap lines at blank.
set nolinebreak

" changed from 78
" no wordwrap.
set textwidth=0

" behaviour of backspace keys in insert mode.
set backspace=2

" syntax highlighting (use dark if the background is dark).
set background=dark

" do not ignore case while searching.
set noignorecase

" show which mode we're in (insert, replace, etc)
set showmode

" display title in X.
set title

" do not keep a search highlighted. 
"set nohlsearch  "OFF as i have it set in my syntax settings

" for in search patterns .. no clue what it does.
set magic

" show current uncompleted command.
set showcmd

" keep cursor in the present column with page commands.
set nostartofline

" <>hl to move to another line if at the start or end of a line.
set whichwrap=<,>,h,l

" EOL, trailing spaces, tabs: show them.
" if `set list' tab is shown as >-----  
" if `set list' a trailing space is shown as a colon.
set nolist
set lcs=tab:>-
set lcs+=trail:.

" what's kept in the file .viminfo.     
set viminfo=%,'50
set viminfo+=\"100,:100
set viminfo+=n~/.viminfo

" tabs are not expanded to spaces (see retab command as well).
set noexpandtab

" switch bell off.
set vb t_vb=

" set the print options.
set printoptions=header:0

" suffixes that get lower priority when doing tab completion for filenames.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" ----------------------------------------------------------------------------
"                                Mappings
" ----------------------------------------------------------------------------

" Handy little thingies:
map <F3> ggVGg?                                 " Switch to and from rot-13
map <F8> gqap                                   " Auto format paragraph
"map <F9> :source ~/.vim/text_dead.vim<CR>      " Dead key functionality.
noremap <F9> :call Switch_DeadKeys()<CR>
map <F4> :colorscheme random<CR>

" Move cursor over visible lines:
noremap <Up> gk
noremap <Down> gj
inoremap <Up> <C-O>gk
inoremap <Down> <C-O>gj

" make search results appear in the middle of the screen:
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

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

" for cvs commit logs
autocmd BufRead cvs*[a-zA-Z0-9] set tw=64
autocmd BufRead cvs*[a-zA-Z0-9] set formatoptions=tqn

" --------------------------------------------------------------------------
"                           SPELLING
" ---------------------------------------------------------------------------

" Spell Checking in VIM from - http://hacktux.com/
" Enable
"set spell

" Enable Spellfile
"set spell spelllang=en_gb
" zg to add word to word list
" zw to reverse
" zug to remove word from word list
" z= to get list of possibilities
"set spellfile=~/.vim/spellfile.add


" Set Colours For Spelling
"highlight clear SpellBad
"highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
"highlight SpellBad term=underline ctermfg=1 term=underline cterm=underline
"highlight clear SpellCap
"highlight SpellCap term=underline cterm=underline
"highlight SpellRare term=underline cterm=underline
"highlight clear SpellLocal
"highlight SpellLocal term=underline cterm=underline

"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>s? z=

" Alternative Spelling options
"set spelllang=en
"set spellfile=~/.vim/en.utf-8.spl.add
"let loaded_spellfile_plugin = 1
" ----------------------------------------------------------------------------
"                              ABBREVIATIONS
" ----------------------------------------------------------------------------

" Tip Taken from http://www.jnrowe.ukfsn.org/articles/configs/vim.html
"
if filereadable(expand("~/.vim/abbr"))
    source ~/.vim/abbr
endif

"Ignore case when searching
set ignorecase
set incsearch

" ----------------------------------------------------------------------------
" Statusline
" ----------------------------------------------------------------------------

"http://www.amix.dk/vim/vimrc.html
"The commandbar is 2 high
set cmdheight=2

"  ~/.vimrc   CWD: /Users/robbie   Line: 309/427,13 72%   Modified: Mon  5 May
"  21:32:34 2008 
"Always hide the statusline
set laststatus=2

function! CurDir()
     let curdir = substitute(getcwd(), '/Users/robbie/', "~/", "g")
     return curdir
  endfunction

autocmd BufWrite  *  call SetStatusLine()
autocmd BufRead   *  call SetStatusLine()


function! SetStatusLine()
	    set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L,%2c\ %p%%\ \ \ Modified:\ %{Time()}
    endfunction

    function! Time()
	        return strftime("%c", getftime(bufname("%")))
	endfunction

"Format the statusline "Alternative
"set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c\ \ \ \ \ \ Time:\ %T
"set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c

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

"Turn backup off
set nobackup
set nowb
set noswapfile


" ----------------------------------------------------------------------------
" Folding
" ----------------------------------------------------------------------------

"Enable folding, I find it very useful
set nofen

" ----------------------------------------------------------------------------
" MISC
" ----------------------------------------------------------------------------
"Remove the Windows ^M
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

"Paste toggle - when pasting something in, don't indent.
set pastetoggle=<F3>

"Remove indenting on empty lines
map <F2> :%s/\s*$//g<cr>:noh<cr>''

"Super paste
inoremap <C-v> <esc>:set paste<cr>mui<C-R>+<esc>mv'uV'v=:set nopaste<cr>

"A function that inserts links & anchors on a TOhtml export.
" Notice:
" Syntax used is:
" Link
" Anchor
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
" For MacVim.app (OS X)
" ----------------------------------------------------------------------------

if has("gui_macvim")
  let macvim_skip_cmd_opt_movement = 1
endif
	
if has("gui_macvim")
  let macvim_hig_shift_movement = 1
endif

" ----------------------------------------------------------------------------
" Paragraphs (HTML)
" ----------------------------------------------------------------------------

"map a shortcut to start a new html paragraph
map \p i<p></p><Esc>hhhi

" ----------------------------------------------------------------------------
" MiniBufEpxplorer
" ----------------------------------------------------------------------------

" minibufexplorer
" ctrl-[hjkl] moves between windows
let g:miniBufExplMapWindowNavVim = 1
" ctrl-tab and ctrl-shift-tab switch between buffers
let g:miniBufExplMapCTabSwitchBufs = 1

" ----------------------------------------------------------------------------
" vim mouse support in gnu screen
" ----------------------------------------------------------------------------

"tell vim that screen supports mouse sequences.
if &term == 'screen'
   set mouse=nic
   set ttymouse=xterm2
endif

" ----------------------------------------------------------------------------

" MyStatusLine {{{

" TODO: add a check for screen width and remove the alternate buffer display
" and args of total display for small screen widths.
function! MyStatusLine()
    let s = '%9* %* ' " pad the edges for better vsplit seperation
    let s .= '%3*' " User highlighting
    let s .= '%%%n '
    if bufname('') != '' " why is this such a pain in the ass? FIXME: there's a bug in here somewhere. Test with a split with buftype=nofile
        let s .= "%{ pathshorten(fnamemodify(expand('%F'), ':~:.')) }" " short-hand path of of the current buffer (use :ls to see more info)
    else
        let s .= '%f' " an empty filename doesn't make it through the above filters
    endif
    let s .= '%*' " restore normal highlighting
    let s .= '%2*' " User highlighting
    let s .= '%m' " modified
    let s .= '%r' " read-only
    let s .= '%w' " preview window
    let s .= '%*' " restore normal highlighting
    let s .= ' %<' " start truncating from here if the window gets too small
    " FIXME: this doens't work well with multiple windows...
    if bufname('#') != '' " if there's an alternate buffer, display the name
        let s .= '%4*' " user highlighting
        let s .= '(#' . bufnr('#') . ' '
        let s .= fnamemodify(bufname('#'), ':t')
        let s .= ')'
        let s .= '%* ' " restore normal highlighting
    endif
    let s .= '%5*' " User highlighting
    let s .= '%y' " file-type
    let s .= '%*' " restore normal highlighting
    let s .= ' <'
    let s .= '%8*' " User highlighting
    let s .= '%{&fileencoding}' " fileencoding NOTE: this doesn't always display, needs more testing
    let s .= '%*,' " restore normal highlighting
    let s .= '%6*' " User highlighting
    let s .= '%{&fileformat}' " line-ending type
    let s .= '%*' " restore normal highlighting
    let s .= '>'
    let s .= '%a' " (args of total)
    let s .= '  %9*' " user highlighting
    let s .= '%=' " seperate right- from left-aligned
    let s .= '%*' " restore normal highlighting
    let s .= '%7*' " user highlighting
    let s .= '  %{VimBuddy()} ' " Vimming will never be lonely again. TODO: check for plugin before loading
    let s .= '%*' " restore normal highlighting
    let s .= '%1*' " User highlighting
    let s .= '%l' " current line number
    let s .= '%*' " restore normal highlighting
    let s .= ',%c' " column number
    let s .= '%V' " virtual column number (doesn't count indentation)
    let s .= ' %1*' " User highlighting
    let s .= 'of %L' " total line numbers
    let s .= '%* ' " restore normal highlighting
    let s .= '%3*' " user highlighting
    let s .= '%P' " Percentage through file
    let s .= '%*' " restore normal highlighting
    let s .= ' %9* %*' " pad the edges for better vsplit seperation
    return s
endfunction
set statusline=%!MyStatusLine()

" }}}

" ----------------------------------------------------------------------------
" ir_black colorscheme
" ----------------------------------------------------------------------------

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

syntax on



" Everything from here on down is optional
" These colors are examples of what is possible
" type :help syntax
" or :help color within vim for more info
" and try opening the file
" share/vim/vim61/syntax/colortest.vim
" Note: where share is depends on where/how you installed vim
 
highlight Comment       ctermfg=green
highlight Constant      ctermfg=DarkMagenta
highlight Character     ctermfg=DarkRed
highlight Special       ctermfg=DarkBlue
highlight Identifier    ctermfg=DarkCyan
highlight Statement     ctermfg=DarkBlue
highlight PreProc       ctermfg=DarkBlue
highlight Type          ctermfg=DarkBlue
highlight Number        ctermfg=Green
highlight Delimiter     ctermfg=DarkBlue
highlight Error         ctermfg=Red
highlight Todo          ctermfg=DarkBlue
highlight WarningMsg    term=NONE           ctermfg=Red ctermbg=NONE   
highlight ErrorMsg      term=NONE           ctermfg=Red ctermbg=NONE 

" These settings only affect the X11 GUI version (which is different
" than the fully Carbonized version at homepage.mac.com/fisherbb/

highlight Comment       guifg=green                 gui=NONE
highlight Constant      guifg=Magenta               gui=NONE
highlight Character     guifg=Red                   gui=NONE
highlight Special       guifg=Blue                  gui=NONE
highlight Identifier    guifg=DarkCyan              gui=NONE
highlight Statement     guifg=DarkGreen             gui=NONE
highlight PreProc       guifg=Purple                gui=NONE
highlight Type          guifg=DarkGreen             gui=NONE
"highlight Normal                   guibg=#E0F2FF   gui=NONE
highlight Number        guifg=Blue                  gui=NONE
"highlight Cursor       guifg=NONE  guibg=Green
"highlight Cursor       guifg=bg    guibg=fg
highlight Delimiter     guifg=blue                  gui=NONE
"highlight NonText                  guibg=green gui=NONE
"highlight Error        guifg=White guibg=Red       gui=NONE
highlight Error         guifg=NONE  guibg=NONE      gui=NONE
highlight Todo          guifg=Blue  guibg=Yellow    gui=NONE



" ----------------------------------------------------------------------------
" ~/.vimrc ends here
" ----------------------------------------------------------------------------
