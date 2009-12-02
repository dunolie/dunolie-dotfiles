" amido is my version of it :)
"
" sivitodo -- "Simple Vim ToDo" list syntax highlighting
"
" Copyright (C) 2006   Josef Kufner <jk@myserver.cz>
"
" Licence:
"	This program is free software; you can redistribute it and/or modify
"	it under the terms of the GNU General Public License as published by
"	the Free Software Foundation; either version 2 of the License, or
"	(at your option) any later version.
"
"	This program is distributed in the hope that it will be useful,
"	but WITHOUT ANY WARRANTY; without even the implied warranty of
"	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"	GNU General Public License for more details.
"
"
" Task Marks:
"  + ... task complete		:)
"  - ... task incomplete	:(
"  x ... task canceled		:P
"  ? ... task is unknown (missing info, depencies, etc...)
"
" File Format:
"  |v--- first column
"  |
"  |+      * something completed
"  |-            * incomplete subtask
"  |-      * another incomplete task
"  |                                           // empty line (no whitespace, CR only)
"  |       some text (not task)
"  |
"  |vim:syntax=sivitodo:
"
"

syntax match sivitodo_ItemMark 			/^[+-x?]/ contained

syntax match sivitodo_ItemMarkIncomplete	/^-[ \t]\+\*[ \t]/ contained contains=sivitodo_ItemMark
syntax match sivitodo_ItemMarkComplete		/^+[ \t]\+\*[ \t]/ contained contains=sivitodo_ItemMark
syntax match sivitodo_ItemMarkCanceled		/^x[ \t]\+\*[ \t]/ contained contains=sivitodo_ItemMark
syntax match sivitodo_ItemMarkUnknown		/^?[ \t]\+\*[ \t]/ contained contains=sivitodo_ItemMark

syntax region sivitodo_ItemIncomplete	start=/^-[ \t]\+\*[ \t]/ end=/^\([-+x?]\|$\)\@>/me=e-1 contains=sivitodo_ItemMarkIncomplete
syntax region sivitodo_ItemComplete	start=/^+[ \t]\+\*[ \t]/ end=/^\([-+x?]\|$\)\@>/me=e-1 contains=sivitodo_ItemMarkComplete
syntax region sivitodo_ItemCanceled	start=/^x[ \t]\+\*[ \t]/ end=/^\([-+x?]\|$\)\@>/me=e-1 contains=sivitodo_ItemMarkCanceled
syntax region sivitodo_ItemUnknown	start=/^?[ \t]\+\*[ \t]/ end=/^\([-+x?]\|$\)\@>/me=e-1 contains=sivitodo_ItemMarkUnknown

syntax sync match sivitodo_ItemMarkIncomplete	grouphere sivitodo_ItemIncomplete /^-[ \t]\+\*[ \t]/
syntax sync match sivitodo_ItemMarkComplete	grouphere sivitodo_ItemComplete	  /^+[ \t]\+\*[ \t]/
syntax sync match sivitodo_ItemMarkCanceled	grouphere sivitodo_ItemCanceled   /^x[ \t]\+\*[ \t]/
syntax sync match sivitodo_ItemMarkUnknown 	grouphere sivitodo_ItemUnknown    /^?[ \t]\+\*[ \t]/

highlight sivitodo_ItemMark		guifg=#777777 cterm=bold ctermfg=darkyellow
highlight sivitodo_ItemComplete		guifg=#80a0ff cterm=NONE ctermfg=darkcyan
highlight sivitodo_ItemMarkComplete	guifg=#00ff00 cterm=bold ctermfg=lightgreen
highlight sivitodo_ItemIncomplete	guifg=#ffa080 cterm=NONE ctermfg=magenta
highlight sivitodo_ItemMarkIncomplete	guifg=#ff0000 cterm=bold ctermfg=lightred
highlight sivitodo_ItemCanceled		guifg=#444466 cterm=NONE ctermfg=darkgrey
highlight sivitodo_ItemMarkCanceled	guifg=#8888aa cterm=bold ctermfg=green
highlight sivitodo_ItemUnknown		guifg=#773333 cterm=NONE ctermfg=darkred
highlight sivitodo_ItemMarkUnknown	guifg=#ff0000 cterm=bold ctermfg=magenta
