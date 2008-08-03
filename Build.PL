use strict;
use warnings;

use Module::Build;

Module::Build->new(
    module_name       => 'Locale::Maketext::TieHash::L10N',
    license           => 'perl',
    dist_abstract     => 'Locale::Maketext::TieHash::L10N - Tying language handle to a hash',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Locale/Maketext/TieHash/L10N.pm',
    requires          => {
        # Carp             => 0, # perl dist
        'Params::Validate' => 0,
    },
    build_requires => {
        'Locale::Maketext' => '1.06',
        'Test::Simple'     => 0, # for Test::More
    },
    recommends => {
        # build
        'Test::Pod'           => '1.14',
        'Test::Pod::Coverage' => '1.04',
        'Test::More'          => 0,
    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script();