use strict;
use warnings;

use Irssi;
use JSON; #JSON-2.x is needed, it won't work 1.x versions
use Text::Iconv;
use LWP::UserAgent;
use URI::Escape;
use HTML::Entities;

our $VERSION = '0.2';
our %IRSSI = (
              authors     => 'Gabor Adam TOTH',
              name        => 'translate',
              description => 'translates messages real-time',
              license     => 'GPL',
              contact     => 'tg at x-net dot hu',
              url         => 'http://scripts.irssi.hu/',
             );

our $B = chr(2);
our $C = chr(3);
our (%settings,$recode,$recode_out);

sub translate {
  my ($text, $from, $to) = @_;
  $from = '' if !$from || $from eq 'auto';
  $to ||= 'en';

  $text =~ s/$B//g;
  $text =~ s/$C\d{2}//g;
  $text = $recode_out->convert($text) || $text if $recode_out;
  $text = uri_escape($text);

  my $ua = LWP::UserAgent->new;
  $ua->agent('Irssi');
  $ua->timeout(5);

  my $request = HTTP::Request->new(GET => "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$text&langpair=$from%7C$to");
  my $result = $ua->request($request);
  my $content = $result->content;
  my $r = decode_json($content);
  return unless ref $r eq 'HASH';
  my $d = $r->{responseData};
  $from ||= $d->{detectedSourceLanguage} || '';
  my $ret;
  if ($r->{responseStatus} == 200 ) {
    $text = $d->{translatedText};
    $ret = 1;
  } else {
    $text = $r->{responseDetails};
    $ret = 0;
  }
  $text = decode_entities($text);
  $text = $recode->convert($text) || $text if $recode;
  return ($ret,$text,$from,$to);
}

Irssi::command_bind('translate',  'cmd_translate');
sub cmd_translate {
  my ($data, $server, $witem) = @_;
  unless ($data) {
    Irssi::print "Usage: /translate from-to text\n       where from and to are 2-character language codes, if from is auto or not specified, it will be auto-detected";
    return;
  }
  my ($ret,$text,$from,$to);
  if ($data =~ /^(\w{2}|auto)?-(\w{2}) (.+)$/) {
    $from = $1;
    $to = $2;
    $text = $3;
  } else {
    $from = Irssi::settings_get_str('translate_default_source');
    $to = Irssi::settings_get_str('translate_default_target');
    $text = $data;
  }
  return unless $to && $text;
  ($ret,$text,$from,$to) = translate($text,$from,$to);
  $text = "$B(($from-$to))$B $text";
  $witem ? $witem->print($text) : Irssi::print($text);
}

sub print_win {
  my ($w, $text) = @_;
  $w ||= Irssi::active_win;
  return unless $w;

  my $line = $w->view->get_lines;
  while ($line && $line->next) {
    $line = $line->next;
  }
  $w->gui_printtext_after($line, MSGLEVEL_CRAP, "$text\n");
  $w->view->redraw;
}

Irssi::signal_add_priority('message private',  'message', 1000);
Irssi::signal_add_priority('message public',  'message', 1000);
sub message {
  my ($server, $msg, $nick, $address, $target) = @_;
  my $len;
  if ($target) {
    $len = Irssi::settings_get_int('translate_nick_decoration_public');
  } else {
    $len = Irssi::settings_get_int('translate_nick_decoration_private');
    $target = $nick;
  }
  my $t = get_targets('translate_targets');
  my $lct = lc $target;
  return unless exists $t->{$lct} && ref $t->{$lct} eq 'ARRAY';
  my ($from,$to) = @{$t->{$lct}};
  return unless $from && $to;
  my ($ret,$text);
  ($ret, $text, $from, $to) = translate($msg, $from, $to);
  return if !$ret || $from eq $to || strip($msg) eq strip($text);
  my $witem = $server->window_find_item($target);
  my $space = ' ' x (length($nick)+$len);
  print_win($witem, "$from-$to $space $text");
}

Irssi::command_bind('msg',  'cmd_msg');
sub cmd_msg {
  my ($data, $server, $witem) = @_;
  return if $data !~ /(?:-nick|-channel) "(\S+)" (.+)/;
  my $target = $1;
  my $msg = $2;

  my $t = get_targets('translate_out_targets');
  my $lct = lc $target;
  return unless exists $t->{$lct} && ref $t->{$lct} eq 'ARRAY';

  my ($from,$to) = @{$t->{$lct}};
  my ($ret, $text);
  ($ret, $text, $from, $to) = translate($msg, $from, $to);
  return if !$ret || $from eq $to || strip($msg) eq strip($text);

  Irssi::signal_stop;
  $server->command("msg $target $text");
}

sub get_targets {
  my ($setting) = @_;
  my $targets = {};
  my @t = split /, */, lc(Irssi::settings_get_str($setting));
  for (@t) {
    if (/^(.+): *(\w+)[|-](\w+)$/) {
      $targets->{$1} = [$2, $3];
    }
  }
  return $targets;
}

Irssi::signal_add('setup changed', 'read_settings');
sub read_settings {
  my $ss = \%settings;
  my $rec = Irssi::settings_get_bool('recode');
  my $term = Irssi::settings_get_str('term_charset');
  my $out = Irssi::settings_get_str('recode_out_default_charset');

  undef $recode if !$rec || $term ne ($ss->{term_charset}||'');
  undef $recode_out if !$rec || $term ne ($ss->{term_charset}||'') || $out ne ($ss->{recode_out_default_charset}||'');

  if ($rec) {
    $recode = new Text::Iconv('UTF8', $term) unless $recode;
    if ($out && $out ne $term) {
      $recode_out = new Text::Iconv($term, $out) unless $recode_out;
    }
  }

  $ss->{recode} = $rec;
  $ss->{term_charset} = $term;
  $ss->{recode_out_default_charset} = $out;
}

sub strip {
  my ($s) = @_;
  $s = lc $s;
  $s =~ s/\W//g;
  return $s;
}

Irssi::settings_add_str($IRSSI{name}, 'translate_targets', '#foo: auto-en, #bar: de-en');
Irssi::settings_add_str($IRSSI{name}, 'translate_out_targets', '#foo: auto-en, #bar: de-en');
Irssi::settings_add_str($IRSSI{name}, 'translate_default_source', 'auto');
Irssi::settings_add_str($IRSSI{name}, 'translate_default_target', 'en');
Irssi::settings_add_int($IRSSI{name}, 'translate_nick_decoration_public', 3);
Irssi::settings_add_int($IRSSI{name}, 'translate_nick_decoration_private', 2);

read_settings;
