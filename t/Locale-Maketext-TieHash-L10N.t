use 5.006001;
use strict;
use warnings;
use Test::More tests => 11;
BEGIN { use_ok('Locale::Maketext::TieHash::L10N') };

# declare some classes...
{ package L10N;
  use base qw(Locale::Maketext);
}
{ package L10N::en;
  use base qw(L10N);
  our %Lexicon = (
    'Beispiel' => 'Example',
    'Ein Gerät besteht aus [*,_1,Teil,Teile,kein Teil].'
    => 'Equipment consists of [*,_1,part,parts,no part].',
    'Baue [*,_1,~Teil,~Teile,kein Teil] zusammen, dann hast Du [*,_2,~Gerät,~Geräte,kein Gerät].'
    => 'Put [*,_1,~component,~components,no component] together, then have [*,_2,~piece,~pieces,no piece] of equipment.',
  );
}

use Locale::Maketext::TieHash::L10N;
my %mt;
print "# create and store language handle\n";
{ my $lh = L10N->get_handle('en') || die "What language?";
  ok $lh && ref $lh;
  tie %mt, 'Locale::Maketext::TieHash::L10N', L10N => $lh;
}
print "# set option numf_comma to 1 and set nbsp_flag to ~\n";
{ my %config = tied(%mt)->Config(numf_comma => 1, nbsp_flag => '~');
  ok
    $config{numf_comma}
    && $config{nbsp_flag} eq '~'
  ;
}
print "# initiating dying by storing wrong options\n";
{ eval { tied(%mt)->Config(undef() => undef) };
  my $error1 = $@ || '';
  eval { tied(%mt)->Config(wrong => undef) };
  my $error2 = $@ || '';
  eval { tied(%mt)->Config(nbsp => undef) };
  my $error3 = $@ || '';
  eval { $mt{nbsp} = undef };
  my $error_deprecated = $@ || '';
  ok
    $error1 =~ /\bkey is not true\b/
    && $error2 =~ /\bkey is not '\b/
    && $error3 =~ /\bkey is 'nbsp', value is undef/
    && $error_deprecated =~ /\bkey is 'nbsp', value is undef/
  ;
}
print "# translate\n";
{ my $text = qq~$mt{Beispiel}:\n$mt{['Ein Gerät besteht aus [*,_1,Teil,Teile,kein Teil].', 5000.5]}\n~;
  my $html = qq#$mt{["Baue [*,_1,~Teil,~Teile,kein Teil] zusammen, dann hast Du [*,_2,~Gerät,~Geräte,kein Gerät].", 2, 1]}\n#;
  ok $text && $html;
  print "# check translation\n";
  ok $text =~ /Example/;
  print "# check option numf_comma\n";
  ok $text =~ /5.000,5/;
  print "# check &nbsp; in HTML\n";
  ok $html =~ /2&nbsp;component.*?1&nbsp;piece/;
}
print "# check method Config()\n";
{ my %cfg = tied(%mt)->Config(nbsp_flag => '~~');
  ok $cfg{L10N} && ref($cfg{L10N}) && $cfg{nbsp} eq '&nbsp;' && $cfg{nbsp_flag} eq '~~';
  () = tied(%mt)->Config(nbsp_flag => '~');
}
print "# check deprecated methods Keys(), Values() and Get(qw/L10N nbsp nbsp_flag/)\n";
@mt{tied(%mt)->Keys} = tied(%mt)->Values;
{ my ($lh, $nbsp, $nbsp_flag) = tied(%mt)->Get(qw/L10N nbsp nbsp_flag/);
  ok $lh && ref($lh) && $nbsp eq '&nbsp;' && $nbsp_flag eq '~';
}
print "# initiating dying by deprecated method Get()\n";
{ eval { tied(%mt)->Get(undef) };
  my $error1 = $@ || '';
  my $value;
  eval { ($value) = tied(%mt)->Get('wrong') };
  my $error2 = $@ || '';
  ok
    $error1 =~ /\bkey is not true\b/
    && $error2 eq ''
    && !defined($value)
  ;
}