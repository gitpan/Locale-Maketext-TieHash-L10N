#!perl -T

use strict;
use warnings;

use Test::More tests => 11;

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
    our %Lexicon = (
        'Beispiel'
            => 'Example',
        'Ein Geraet besteht aus [*,_1,Teil,Teile,kein Teil].'
            => 'Equipment consists of [*,_1,part,parts,no part].',
        'Baue [*,_1,~Teil,~Teile,kein Teil] zusammen, dann hast Du [*,_2,~Geraet,~Geraete,kein Geraet].'
            => 'Put [*,_1,~component,~components,no component] together, then have [*,_2,~piece,~pieces,no piece] of equipment.',
    );
}

package main;

# set language handle
tie my %mt, 'Locale::Maketext::TieHash::L10N', (
    L10N => L10N->get_handle('en')
            || die 'What language?',
);

# config for lexikon
{
    my %cfg = tied(%mt)->config(numf_comma => 1, nbsp_flag => '~');
    ok(
        $cfg{numf_comma},
        'set option numf_comma to 1',
    );
    is(
        $cfg{nbsp_flag},
        '~',
        'set nbsp_flag to ~',
    );
}

# translate
{
    my $text = qq{$mt{Beispiel}:\n$mt{['Ein Geraet besteht aus [*,_1,Teil,Teile,kein Teil].', 5000.5]}\n};
    ok(
        $text,
        'translate text',
    );
    like(
        $text,
        qr{Example}xms,
        'check translation',
    );
    like(
        $text,
        qr{5\.000,5}xms,
        'check option numf_comma',
    );
}

# quant
{
    my $html = qq{$mt{["Baue [*,_1,~Teil,~Teile,kein Teil] zusammen, dann hast Du [*,_2,~Geraet,~Geraete,kein Geraet].", 2, 1]}\n};
    ok(
        $html,
        'translate html',
    );
    like(
        $html,
        qr{2 &nbsp; component .*? 1 &nbsp; piece}xms,
        'check &nbsp; in HTML',
    );
}

# check config and get/set-methods behind
{
    my %cfg = tied(%mt)->config(nbsp_flag => '~~');
    isa_ok(
        $cfg{L10N},
        'Locale::Maketext',
        'check method config, L10N',
    );
    is(
        $cfg{nbsp},
        '&nbsp;',
        'check method config, nbsp',
    );
    is(
        $cfg{nbsp_flag},
        '~~',
        'check method config, nbsp_flag',
    );
}