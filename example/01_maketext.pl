#!perl

# base class
package L10N;

use strict;
use warnings;

use parent qw(Locale::Maketext);

1;

#-----------------------------------------------------------------------------

# german lexikon
package L10N::de; ## no critic (MultiplePackages Capitalization)

use strict;
use warnings;

use parent qw(-norequire L10N);

our %Lexicon = ( ## no critic (Capitalization PackageVars)
    'Example'
        => 'Beispiel',
    'Can not open file [_1]: [_2].'
        => 'Datei [_1] konnte nicht geoeffnet werden: [_2].',
);

1;

#-----------------------------------------------------------------------------

package main; ## no critic (MultiplePackages)

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use Locale::Maketext::TieHash::L10N;

# tie and configure
tie my %mt, 'Locale::Maketext::TieHash::L10N', ( ## no critic (Ties)
    # save language handle
    L10N => L10N->get_handle('de_DE')
            || croak 'What language?',
);

my $file_name = 'myFile';
my $is_open = open my $file_handle, '<', $file_name;
if (! $is_open) {
    () = print <<"EOT";
$mt{Example}:
$mt{[ 'Can not open file [_1]: [_2].', $file_name, $! ]}
EOT
}
() = close $file_handle;

# $Id$