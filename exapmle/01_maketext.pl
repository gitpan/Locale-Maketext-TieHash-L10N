#!perl

# base class
package L10N;

use strict;
use warnings;

use parent qw(Locale::Maketext);

1;

#-----------------------------------------------------------------------------

# german lexikon
package L10N::de;

use strict;
use warnings;

use parent qw(-norequire L10N);

our %Lexicon = (
    'Example'
        => 'Beispiel',
    'Can not open file [_1]: [_2].'
        => 'Datei [_1] konnte nicht geoeffnet werden: [_2].',
);

1;

#-----------------------------------------------------------------------------

package main;

use strict;
use warnings;

use Locale::Maketext::TieHash::L10N;

# tie and configure
tie my %mt, 'Locale::Maketext::TieHash::L10N', (
    # save language handle
    L10N => L10N->get_handle('de_DE')
            || die 'What language?',
);

my $file_name = 'myFile';
if (! open my $file_handle, '<', $file_name) {
    print <<"EOT";
$mt{Example}:
$mt{[ 'Can not open file [_1]: [_2].', $file_name, $! ]}
EOT
}