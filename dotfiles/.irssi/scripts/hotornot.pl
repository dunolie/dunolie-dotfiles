# /horny - Show URLs to random Hot-or-Not girls' pictures.
#
# /horny
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# 
#	Version 0.1 - 2006-07-29 - Tim A Johansson tim@gurka.se
#  Initial release
#

use Irssi;
use vars qw($VERSION %IRSSI); 
$VERSION = "0.1";
%IRSSI = (
	authors	=> "Tim A Johansson",
	contact	=> "tim\@gurka.se",
	name	=> "Irssi Hot-or-not",
	description	=> "/horny - Show URLs to random Hot-or-Not girls' pictures.",
	license	=> "GPL",
	url		=> "http://timjoh.com/irssi-plugin-hot-or-not/",
);

sub cmd_horny {
	use LWP::Simple;
	my $max_age = '25';
	my $min_rating = '8.1';
	for (my $i = 0; $i < 1; $i++) {
		$_ = get("http://services.hotornot.com/rest/?app_key=479NUNJHETN&method=Rate.getRandomProfile&retrieve_num=1&gender=female&max_age=$max_age&min_rating=$min_rating&get_rate_info=true");
		# Please don't steal my API key. Get your own for free at http://dev.hotornot.com/. It is used for tracking applicatons.
		if (m/gender>(.*?)<.*?age>(.*?)<.*?pic_url>(.*?)<.*?rating>(.*?)</) {
			Irssi::print($2 . ' years old ' . $1 . ', rated ' . $4 . '. Enjoy. ' . $3);
		} else {
			Irssi::print('%R• %rError:%K could not recognize string: ' . $_);
		}
	}
}

Irssi::command_bind('horny', 'cmd_horny');
