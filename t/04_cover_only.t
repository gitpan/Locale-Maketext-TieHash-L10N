#!perl -T

use strict;
use warnings;

use Test::More tests => 5;
BEGIN {
    use_ok('Locale::Maketext::TieHash::L10N');
}

# base class
{
    package L10N;
    use base qw(Locale::Maketext);
}

# lexicon
{
    package L10N::en;
    use base qw(L10N);
    our %Lexicon = (
        unbekannt => 'unknown ~',
    );
}

package main;

tie my %mt, 'Locale::Maketext::TieHash::L10N', (
    L10N => L10N->get_handle('en')
            || die 'What language?',
);

eval {
    () = $mt{test};
};
like(
    $@,
    qr{how to say}ms,
    'translation error',
);

# nbsp_flag not defined
is(
    $mt{unbekannt},
    'unknown ~',
    'nbsp_flag is not defined'
);

# length nbsp_flag == 0
(tied %mt)->set_nbsp_flag( q{} );
is(
    $mt{unbekannt},
    'unknown ~',
    'nbsp_flag is q{}'
);

(tied %mt)->set_nbsp( undef );
(tied %mt)->set_nbsp_flag('~');
is(
    $mt{unbekannt},
    'unknown',
    'nbsp is undef, nbsp_flag is q{}'
);