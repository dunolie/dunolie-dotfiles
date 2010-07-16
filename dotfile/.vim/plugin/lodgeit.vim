" lodgeit.vim: Vim plugin for paste.pocoo.org
" Maintainer:	Armin Ronacher <armin.ronacher@active-4.com>
" Version:	0.1

" Usage:
" 	:Lodgeit	create a paste from the current buffer of selection
"
" If you want to paste on ctrl + p just add this to your vimrc:
" 	map ^P :Lodgeit<CR>
" (where ^P is entered using ctrl + v, ctrl + p in vim)

function! s:Lodgeit(line1,line2,count)
python << EOF

import vim
from xmlrpclib import ServerProxy
pastes = ServerProxy('http://paste.pocoo.org/xmlrpc/').pastes

rng_start = int(vim.eval('a:line1')) - 1
rng_end = int(vim.eval('a:line2'))
rng_count = int(vim.eval('a:count'))
if rng_count:
    code = '\n'.join(vim.current.buffer[rng_start:rng_end])
else:
    code = '\n'.join(vim.current.buffer)

lng_code = {
    'python':           'python',
    'php':              'html+php',
    'smarty':           'smarty',
    'tex':              'tex',
    'rst':              'rst',
    'cs':               'csharp',
    'haskell':          'haskell',
    'xml':              'xml',
    'html':             'html',
    'xhtml':            'html',
    'htmldjango':       'html+django',
    'django':           'html+django',
    'htmljinja':        'html+django',
    'jinja':            'html+django',
    'lua':              'lua',
    'scheme':           'scheme',
    'mako':             'html+mako',
    'c':                'c',
    'cpp':              'cpp',
    'javascript':       'js',
    'jsp':              'jsp',
    'ruby':             'ruby',
    'bash':             'bash',
    'bat':              'bat',
    'd':                'd',
    'genshi':           'html+genshi'
}.get(vim.eval('&ft'), 'text')

paste_id = pastes.newPaste(lng_code, code)
url = 'http://paste.pocoo.org/show/%d' % paste_id

print 'Pasted #%d to %s' % (paste_id, url)
vim.command(':call setreg(\'+\', %r)' % url)

EOF
endfunction

command! -range=0 Lodgeit :call s:Lodgeit(<line1>,<line2>,<count>)
