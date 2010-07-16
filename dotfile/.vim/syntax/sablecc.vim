" Vim syntax file
" Language: sablecc
" Maintainer:	Roger Keays <s354157@student.uq.edu.au>
" Last Change:	2001 Dec 17
" Bugs: The + operator should probably only be highlighted
"       when used as a part of a regex (not set construction)

" To install, put this file in ~/.vim/syntax/
" and add the lines
"   autocmd BufEnter *.sablecc set syntax=sablecc
"   au Syntax sablecc so $HOME/.vim/syntax/sablecc.vim
" to your ~/.vimrc file

" Remove any old syntax stuff hanging around.
syn clear
syn case match

syn keyword KEYWORD 	Package States Helpers Tokens Ignored Productions

" Numbers, characters.
syn match Number	"[+-]\=[0-9][0-9]*\.\=[0-9]*"
syn match Number	"0[x\|X][a-fA-F]*"
syn match Structure	"\[\|\]\|(\|)\|?\|\*\|+\||"
syn match Tag		"\[[a-z][a-z_0-9]*\]"
syn match Identifier	"[[a-z][a-z_0-9]*\s*="
syn match String	"'.'"
"syn match Comment	"\/\/.*$"

" Strings, names, comments
" syn region String	start=.'. end=.'.
syn region Label	start=.{. end=.}.
syn region Comment	oneline start=.//. end=.$.
syn region Comment	start=./\*. skip=./\*. end=.\*/.

if !exists("did_sablecc_syntax_inits")
  let did_sablecc_syntax_inits = 1
  hi Comment ctermfg=Blue
endif

let b:current_syntax = "sablecc"

" vim: ts=8
