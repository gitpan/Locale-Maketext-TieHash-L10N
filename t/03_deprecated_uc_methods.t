#!perl -T

use strict;
use warnings;

use Test::More tests => 2 + 1;
use Test::NoWarnings;

BEGIN {
    use_ok('Locale::Maketext::TieHash::L10N');
}

# base class
{
    package L10N;
    use base qw(Locale::Maketext);
}

# english lexikon
{
    package L10N::en;
    use base qw(L10N);

    no warnings qw(once);
    our %Lexicon = ();
}

# set language handle
tie my %mt, 'Locale::Maketext::TieHash::L10N', (
    L10N => L10N->get_handle('en')
            || die 'What language?',
);

# method Config
{
    tied(%mt)->Config(nbsp_flag => '~');
    is(
        tied(%mt)->get_nbsp_flag(),
        '~',
        'check deprecated method Config',
    );
}