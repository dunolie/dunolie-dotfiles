"########################################################################
" By Robbie -- dunolie@gmail.com
" Created on: Saturday,31 January, 2009
" Description: gvimrc (for macvim)
" Snipped from website :
" Snipped from IRC channel :
" Snipped from :
" Last modified: Tue Oct 27, 2009 02:24am
"#######################################################################

set guifont=Menlo:13
""set gcr=b:blinkon0"
colorscheme 256_ir_black
set lines=50
set columns=130
set go-=T
set bg=dark
if &background == "dark"
    hi normal guibg=black
    set transp=0
endif
"set transp=8
set gcr=a:blinkon0
"Open up Terminal and type

"defaults write org.vim.MacVim AppleSmoothFixedFontsSizeThreshold 1
"Monaco 10pt is jagged even though 'antialias' is set

"defaults write org.vim.MacVim AppleShowAllFiles 1
"How to make Open and Save dialogs show hidden files
" Tab headings
set gtl=%t gtt=%F

"FuzzyFinderTextMate
nnoremap <silent><D-r> :FuzzyFinderTextMate<CR>

" save
noremap <silent> <D-s> :w<CR>


let macvim_skip_cmd_opt_movement = 1
let macvim_hig_shift_movement = 1


