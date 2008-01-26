use strict;
use warnings;

use Module::Build;

Module::Build->new(
    module_name       => 'Locale::Maketext::TieHash::L10N',
    license           => 'perl',
    dist_author       => 'Steffen Winkler <steffenw@cpan.org>',
    dist_version_from => 'lib/Locale/Maketext/TieHash/L10N.pm',
    requires          => {
        Carp               => 0,
        'Params::Validate' => 0,
    },
    build_requires => {
        'Locale::Maketext' => 1.06,
        'Test::More'       => 0,

    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script();
