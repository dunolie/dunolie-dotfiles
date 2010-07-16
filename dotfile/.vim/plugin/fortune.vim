"
"        Author: Srinath Avadhanula
"          File: fortune.vim
"   Last Change: Wed Jan 30 01:00 AM 2002 PST
"       Contact: srinath@fastmail.fm
"     Copyright: are you serious?
" 
" This script provides a way to have vim put a fortune at the end of your mail
" messages. Most unix mail clients automatically handle the capability of
" having a program output as the signature file, but with most windows mail
" clients, (at least PC-pine) do not (yet) provide a way to do this. This
" script provides a vim way to do the equivalent, if your mail client is
" capable of using external editors to compose mails. 
"
" In addition, this script also provides a way to change the style in which
" you quote the reply to your mails. by default, PC-pine quotes messages with
" the header:
"    On Sat 12 Jun 2001, John Doe wrote:
" too boring? 
" This script will change this to:
"    In our last exciting episode on Sat 12 Jun 2001, John Doe said:
"  You can ofcourse customize this to your special whackiness by changing the
"  function ReplaceQuote().
" 
" INSTALLATION:
" 1. download the file into your ~/.vim/plugin directory.
" 2. create a signature file which looks like:
"     -----%<-----
"     -- 
"     Srinath Avadhanula
"     _REPLACE_WITH_FORTUNE_
"     -----%<-----
"    (only the last line is necessary).
" 3. in your mail client configuration, set this as your signature file. 
"    (for pine, this is in the configuration screen).
" 4. download and install the fortune program somewhere so that its in your
"    path and vim can source its output with a simple ". ! fortune" command.
"    if you have cygwin installed, then running a google search for "fortune
"    cygwin" turns up many relevant hits. just download the relevant .tar.gz
"    file and untar it into cygwin's root directory.
" 
" You will need to use a mail client which is capable of using external
" editors to compose mails. (Outlook readily dissapears from my mind).
" Some mail clients on windows platforms having this feature:
"
"    PC-pine: http://www.washington.edu/pine/pc-pine/
"   Mahogany: http://mahogany.sourceforge.net/
"
" (I've been using PC-pine exclusively for many moons now).
"
" NOTE:
" If the fancy mail quoting does not seem to be working for you check that
" your mail client quotes replies either with the header:
"    On Sat 12 Jun 2001, John Doe wrote:
" or
"    On 12 Jun 2001, John Doe wrote:
" If its some other format, you will need to tweak the function
" ReplaceQuote() (please consider sending me a patch if you do this). 
"
"

" this function replaces a line called "_REPLACE_WITH_FORTUNE_" with the
" the output of the fortune command. to use this with PC-pine, create a
" signature file such as:
" 
" -----%<-----
" -- 
" Srinath Avadhanula
" _REPLACE_WITH_FORTUNE_
" -----%<-----
"
" then if you enter that window while composing the mail, it will be replaced
" with the output of the fortune command. the fortune command for windows can
" be easily installed if you already have cygwin.
"
" note that you need to have fortune in the PATH so that vim can use !fortune
" to run it.
"
function! <SID>ReplaceWithFortune()
	if exists("doneFortune_".bufnr('%'))
		return
	end
	normal! ma
	if search('_REPLACE_WITH_FORTUNE_')
		. ! fortune
	else
		return
	end
	0
	call s:ReplaceQuote()
	normal! 'a
	exe 'let doneFortune_'.bufnr('%').' = 1'
	w
endfunction


" 
" this function changes the quoting style of vim. By default, PC-pine quotes
" messages you reply to with the header
"
" On Day dd Mnt YYYY, Someone Else wrote:
"
" This function changes that to:
"
" In our last exciting episode on Day dd Mnt YYYY, Someone Else said:
"
" you can customize the message by varying the quotefirst, qutoemiddle, and
" quoteend variables.
"
" NOTE: you might need to change this function to suit the special way in
" which your mail client quotes messages.
"
function! <SID>ReplaceQuote()
	let weekdays = '(Mon|Tue|Wed|Thu|Fri|Sat|Sun), '
	let monthdays = '([0-9]{1,2})'
	let months = '(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'
	let year = '([0-9]{4})'
	
	let quotefirst = 'In our last exciting episode, on '
	let quotemiddle = ', '
	let quoteend = ' said'
	
	if search('\v^On '.weekdays.monthdays.' '.months.' '.year.', (.+) wrote')
		exe 's/\v^On '.weekdays.monthdays.' '.months.' '.year.', (.+) wrote/'.quotefirst.'\1, \2 \3 \4'.quotemiddle.'\5'.quoteend.'/'
	elseif search('\v^On '.monthdays.' '.months.' '.year.', (.+) wrote')
		exe 's/\v^On '.monthdays.' '.months.' '.year.', (.+) wrote/'.quotefirst.'\1 \2 \3'.quotemiddle.'\4'.quoteend.'/'
	else
		return
	end
	normal! j
	if getline('.') =~ '^\s*$'
		d
	end
endfunction

" set up the filetype autocommand for doing this.
augroup Fortune
	au!
	au FileType mail call <SID>ReplaceWithFortune()
augroup END
