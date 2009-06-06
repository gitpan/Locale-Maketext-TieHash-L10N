#!perl -T

use strict;
use warnings;

use Test::More tests => 6 + 1;
use Test::Exception;
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

# check methods Keys, Values and Get
{
    my $object = tied %mt;
    $object->set_nbsp_flag('~');
    @mt{$object->Keys()} = $object->Values();
    my ($lh, $nbsp, $nbsp_flag) = $object->Get(qw(L10N nbsp nbsp_flag));
    isa_ok(
        $lh,
        'Locale::Maketext',
        'check deprecated methods Keys, Values and Get, test L10N',
    );
    is(
        $nbsp,
        '&nbsp;',
        'check deprecated methods Keys, Values and Get, test nbsp',
    );
    is(
        $nbsp_flag,
        '~',
        'check deprecated methods Keys, Values and Get, test nbsp_flag',
    );
}

# exceptions
{
    my $object = tied %mt;
    throws_ok(
        sub {
            $object->Get(undef);
        },
        qr{\QGet was an 'undef'\E}xms,
        'initiating dying by deprecated method Get()',
    );
    throws_ok(
        sub {
            $object->Get('wrong');
        },
        qr{get_wrong}xms,
        'get wrong key',
    );
}