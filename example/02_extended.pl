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
use charnames qw(:full);
use Readonly qw(Readonly);

{
    # The browser shows value and unit always on a line.
    Readonly my $IS1 => "\N{INFORMATION SEPARATOR ONE}";

    our %Lexicon = (  ## no critic (Capitalization PackageVars)
        "Put [*,_1,${IS1}component,${IS1}components,no component] together, then have [*,_2,${IS1}piece,${IS1}pieces,no piece] of equipment."
            => "Baue [*,_1,${IS1}Teil,${IS1}Teile,kein Teil] zusammen, dann hast Du [*,_2,${IS1}Geraet,${IS1}Geraete,kein Geraet].",
    );
}

1;

#-----------------------------------------------------------------------------

package main; ## no critic (MultiplePackages)

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(croak);
use Locale::Maketext::TieHash::L10N;
use charnames qw(:full);
use Readonly qw(Readonly);
use POSIX qw(floor);

# The browser shows value and unit always on a line.
Readonly my $IS1 => "\N{INFORMATION SEPARATOR ONE}";

# tie and configure
tie my %mt, 'Locale::Maketext::TieHash::L10N', ( ## no critic (Ties)
    # save language handle
    L10N => ( L10N->get_handle('de_DE') or croak 'What language?' ),
    # set option numf_comma to change . and , inside of numbers
    numf_comma => 1,
    # For no-break space between number and dimension unit
    # set the "nbsp_flag" to a placeholder
    # like "\N{INFORMATION SEPARATOR ONE}" or something else.
    nbsp_flag  => "\N{INFORMATION SEPARATOR ONE}",
    # For Unicode set "nbsp" to "\N{NO-BREAK SPACE}".
    # For testing set "nbsp" to a string which you see in the Browser
    # like:
    nbsp       => '(nbsp)',
);

for (my $component = 0; $component <= 4; $component += .5) { ## no critic (CStyleForLoops MagicNumbers)
    my $piece = floor $component / 2;
    () = print <<"EOT";
$mt{["Put [*,_1,${IS1}component,${IS1}components,no component] together, then have [*,_2,${IS1}piece,${IS1}pieces,no piece] of equipment.", $component, $piece]}
EOT
}

# $Id$