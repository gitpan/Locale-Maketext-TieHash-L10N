use 5.006001;
use strict;
use warnings;
use Test::More tests => 10;
BEGIN { use_ok('Locale::Maketext::TieHash::L10N') };

# declare some classes...
{ package L10N;
  use base qw(Locale::Maketext);
}
{ package L10N::en;
  use base qw(L10N);
  our %Lexicon = (
    'Beispiel' => 'Example',
    'Ein Ger�t besteht aus [*,_1,Teil,Teile,kein Teil].'
    => 'Equipment consists of [*,_1,part,parts,no part].',
    'Baue [*,_1,~Teil,~Teile,kein Teil] zusammen, dann hast Du [*,_2,~Ger�t,~Ger�te,kein Ger�t].'
    => 'Put [*,_1,~component,~components,no component] together, then have [*,_2,~piece,~pieces,no piece] of equipment.',
  );
}

use Locale::Maketext::TieHash::L10N;
tie my %mt, 'Locale::Maketext::TieHash::L10N';
print "# create and store language handle\n";
{ my $lh = L10N->get_handle('en') || die "What language?";
  ok $lh && ref $lh;
  $mt{L10N} = $lh;
}
print "# set option numf_comma to 1 and set nbsp_flag to ~\n";
@mt{qw/numf_comma nbsp_flag/} = qw/1 ~/;
ok 1;
print "# initiating dying by storing wrong options\n";
{ eval { no warnings; $mt{undef()} = undef };
  my $error1 = $@ || '';
  eval { $mt{wrong} = undef };
  my $error2 = $@ || '';
  eval { $mt{nbsp} = undef };
  my $error3 = $@ || '';
  ok $error1 =~ /\bkey is not true\b/ && $error2 =~ /\bkey is not '\b/ && $error3 =~ /\bkey is 'nbsp', value is undef/;
}
print "# translate\n";
{ my $text = qq~$mt{Beispiel}:\n$mt{['Ein Ger�t besteht aus [*,_1,Teil,Teile,kein Teil].', 5000.5]}\n~;
  my $html = qq#$mt{["Baue [*,_1,~Teil,~Teile,kein Teil] zusammen, dann hast Du [*,_2,~Ger�t,~Ger�te,kein Ger�t].", 2, 1]}\n#;
  ok $text && $html;
  print "# check translation\n";
  ok $text =~ /Example/;
  print "# check option numf_comma\n";
  ok $text =~ /5.000,5/;
  print "# check &nbsp; in HTML\n";
  ok $html =~ /2&nbsp;component.*?1&nbsp;piece/;
}
print "# check Keys(), Values() and Get(qw/L10N nbsp nbsp_flag/)\n";
@mt{tied(%mt)->Keys} = tied(%mt)->Values;
{ my ($lh, $nbsp, $nbsp_flag) = tied(%mt)->Get(qw/L10N nbsp nbsp_flag/);
  ok $lh && ref($lh) && $nbsp eq '&nbsp;' && $nbsp_flag eq '~';
}
print "# initiating dying by Get()\n";
{ eval { tied(%mt)->Get(undef) };
  my $error1 = $@ || '';
  eval { tied(%mt)->Get('wrong')};
  my $error2 = $@ || '';
  ok $error1 =~ /\b\QGet(undef) detected\E\b/ && $error2 =~ /\bunknown 'wrong'/;
}