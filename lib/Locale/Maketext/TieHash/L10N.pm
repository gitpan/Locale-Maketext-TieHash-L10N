package Locale::Maketext::TieHash::L10N;

use strict;
use warnings;

our $VERSION = '0.06';

use Carp qw(croak);
use Params::Validate qw(:all);

sub TIEHASH {
    my ($class, %init) = validate_pos(
        @_,
        {type  => SCALAR},
        ({type => SCALAR}, 1) x ((@_ - 1) / 2),
    );
    validate_with(
        params      => \%init,
        spec        => {
            L10N => {isa => 'Locale::Maketext'},
        },
        allow_extra => 1,
    );

    my $self = bless {}, $class;
    $self->config(nbsp => '&nbsp;', %init);

    return $self;
}

sub config {
    # Object, key or parameter hash
    my ($self, %config) = validate_pos(
        @_,
        {isa   => __PACKAGE__},
        ({type => SCALAR}, 1) x ((@_ - 1) / 2),
    );
    my @object_keys = qw(L10N nbsp nbsp_flag numf_comma);
    validate_with(
         params => \%config,
         spec => {
             map {$_ => 0} @object_keys,
         },
         called => 'the config hash of the config method',
    );

    # write config
    for my $key (keys %config) {
        my $method = "set_$key";
        $self->$method($config{$key});
    }

    # read config
    if (defined wantarray) {
        for my $key (@object_keys) {
            my $method = "get_$key";
            $config{$key} = $self->$method();
        }
        return %config;
    }

    return;
}

sub set_L10N {
    my ($self, $L10N) = validate_pos(
        @_,
        {isa => __PACKAGE__},
        {isa => 'Locale::Maketext'},
    );

    $self->{L10N} = $L10N;

    return $self;
}

sub get_L10N {
    my ($self) = validate_pos(
        @_,
        {isa => __PACKAGE__},
    );

    return $self->{L10N};
}

sub set_nbsp {
    my ($self, $nbsp) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
        {type => SCALAR | UNDEF},
    );

    $self->{nbsp} = $nbsp;

    return $self;
}

sub get_nbsp {
    my ($self) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
    );

    return $self->{nbsp};
}

sub set_nbsp_flag {
    my ($self, $nbsp_flag) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
        {type => SCALAR | UNDEF},
    );

    $self->{nbsp_flag} = $nbsp_flag;

    return $self;
}

sub get_nbsp_flag {
    my ($self) = validate_pos(
        @_,
        {isa => __PACKAGE__},
    );

    return $self->{nbsp_flag};
}

sub set_numf_comma {
    my ($self, $numf_comma) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
        {type => SCALAR | UNDEF},
    );

    $self->get_L10N()->{numf_comma} = $numf_comma;
}

sub get_numf_comma {
    my ($self) = validate_pos(
        @_,
        {isa => __PACKAGE__},
    );

    return $self->get_L10N()->{numf_comma};
}

# translate
sub FETCH {
    # Object, Key
    my ($self, $key) = validate_pos(
        @_,
        {isa  => __PACKAGE__},
        {type => SCALAR | ARRAYREF},
    );

    my $text;
    eval {
        # Several parameters to maketext will submit as reference on an array.
        $text = $self->get_L10N()->maketext(
            ref $key eq 'ARRAY'
            ? @{$key}
            : $key
        );
    };
    $@ and croak $@;
    # During the translation the 'nbsp_flag' becomes blank put respectively behind one.
    # These so highlighted blanks are substituted after the translation into '&nbsp;'.
    my $nbsp_flag = $self->get_nbsp_flag();
    if (defined $nbsp_flag && length $nbsp_flag) {
        my $nbsp = $self->get_nbsp();
        if (! defined $nbsp) {
            $nbsp = q{};
        }
        $text =~ s{\Q $nbsp_flag\E}{$nbsp}xmsg;
    }

    return $text;
}

# deprecated
sub Config {
    goto &config;
}

# deprecated
sub Get {
    my ($self, @keys) = validate_pos(
        @_,
        {isa   => __PACKAGE__},
        ({type => SCALAR}) x (@_ - 1),
    );

    return map {
        my $method = "get_$_";
        $self->$method();
    } @keys;
}

# deprecated
sub Keys {
    return keys %{ { shift->config() } };
}

# deprecated
sub Values {
    return values %{ { shift->config() } };
}

# deprecated
sub STORE {
   goto &config;
}

1;

__END__

=pod

=head1 NAME

Locale::Maketext::TieHash::L10N - Tying language handle to a hash

=head1 VERSION

0.06

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Locale::Maketext::TieHash::L10N;
    use MyProgram::L10N;

    # tie and configure
    tie my %mt, 'Locale::Maketext::TieHash::L10N', (
        # save language handle
        L10N       => MyProgram::L10N->get_handle()
                      || die 'What language?',
        # set option numf_comma
        numf_comma => 1,
    );

    ...

    print <<"EOT";
    $mt{Example}:
    $mt{[ q{Can't open file [_1]: [_2].}, $f, $! ]}
    EOT

=head2 The way without this module - You better see the difference.

    use strict;
    use warnings;

    use MyProgram::L10N;

    my $lh = MyProgram::L10N->get_handle()
        or die 'What language?';
    $lh{numf_comma} = 1;

    ...

    # no string interpolation for translation
    print
        $lh->maketext('Example') 
        . ":\n"
        . $lh->maketext( q{Can't open file [_1]: [_2].}, $f, $! ) 
        . "\n";

=head2 Example for writing HTML

    use strict;
    use warnings;

    use Locale::Maketext::TieHash::L10N;
    use MyProgram::L10N;
    use charnames qw(:full);
    use Reasonly qw(Readonly);

    tie my %mt, 'Locale::Maketext::TieHash::L10N', (
        # save language handle
        L10N       => MyProgram::L10N->get_handle()
                      || die 'What language?',
        # set option numf_comma
        numf_comma => 1,
        # For no-break space between number and dimension unit
        # set the "nbsp_flag" to a placeholder
        # like "\N{UNIT SEPARATOR}}" or something else.
        nbsp_flag  => "\N{UNIT SEPARATOR}",
        # For Unicode set "nbsp" to "\N{NO-BREAK SPACE}".
        # For testing set "nbsp" to a string which you see in the Browser
        # like:
        nbsp       => '<span style="color:red">_</span>',
    );

    ...

    # The browser shows value and unit always on a line.
    Readonly my $US => "\N{UNIT SEPARATOR}";
    print <<"EOT";
    $mt{["Put [*,_1,${US}component,${US}components,no component] together, then have [*,_2,${US}piece,${US}pieces,no piece] of equipment.", $component, $piece]}
    EOT

=head2 read Configuration

    my %config = tied(%mt)->config();

=head2 write Configuration

    tied(%mt)->config(numf_comma => 0, nbsp_flag => q{});

or

    my %config = tied(%mt)->config(numf_comma => 0, nbsp_flag => undef);

=head1 DESCRIPTION

Object methods like 'maketext' don't have interpreted into strings.
The module ties the language handle to a hash.
The object method 'maketext' is executed at fetch hash.
At long last this is the same, only the notation is shorter.

Sometimes the object method 'maketext' expects more than 1 parameter.
Then submit a reference on an array as hash key.

If you write HTML text with 'Locale::Maketext',
it then can happen that value and unity stand on separate lines.
The 'nbsp_flag' prevents the line break.
The 'nbsp_flag' per default is undef and this functionality is switched off.
Set your choice this value on a character string.
For switching the functionality off,
set the value to undef or a character string of the length 0.
'nbsp' per default is '&nbsp;'.

=head1 SUBROUTINES/METHODS

=head2 method TIEHASH

Tie the hash and set options defaults.

    use Locale::Maketext::TieHash::L10N;
    tie my %mt, 'Locale::Maketext::TieHash::L10N', %config;

=head2 method config

It's an multiple get-/setter.
Accepts all parameters as Hash and gives a Hash back with all options.

    my %full_config = tied(%mt)->config(
        key1 => $value1,
        ...
    );

or

    my %full_config = tied(%mt)->config();

=head2 method set_L10N

Set the language handle.

    tied(%mt)->set_L10N($lh);

=head2 method get_L10N

Get the langusage handle.

    $lh = tied(%mt)->get_L10N();

=head2 method set_numf_comma

Configure the numf_comma option of the language handle
to change . and , inside of numbers.

    tied(%mt)->set_numf_comma(1);

=head2 method get_numf_comma

Get the numf_comma option of the language hndle.

   $numf_comma = tied(%mt)->get_numf_comma();

=head2 method set_nbsp

Set the no-break space string.
The default is '&nbsp;'.

    # using unicode
    tied(%mt)->set_nbsp("\N{NO-BREAK SPACE}");

    # for debugging a HTML response
    tied(%mt)->set_nbsp('see_position_of_nbsp_in_HTML_response');

=head2 method get_nbsp

Get the no-break space string.

    $nbsp = tied(%mt)->get_nbsp();

=head2 method set_nbsp_flag

Set a flag to say:

Substitute the whitespace before this flag and this flag
to no-break space
or to the debugging string.

The 'nbsp_flag' is a string (1 or more characters).

    tied(%mt)->set_nbsp_flag("\N{UNIT SEPARATOR}");

=head2 method get_nbsp_flag

    $nbsp_flag = tied(%mt)->get_nbsp_flag();

=head2 method FETCH

Translate the given key of the hash
and give back the translated string as value.

    # translation
    print $mt{'you write this language'};

    # the same is:
    print $lh->maketext('you write this language');

    ...

    print $mt{['Put [*,_1,component,components,no component] together.', $number]};

    # the same is:
    print $lh->maketext('Put [*,_1,component,components,no component] together.', $number);

    ...

    # Use "nbsp" and the "nbsp_flag".
    print $mt{["Put [*,_1,${US}component,${US}components,no component] together.", $number]};

    # the same is:
    my $translation = $lh->maketext("Put [*,_1,${US}component,${US}components,no component] together.", $number);
    $tanslation =~ s{ $US}{\N{NO-BREAK SPACE}}msg; # But no global debugging function is available.

The method calls croak, if the method 'maketext' of your stored language handle dies.

=head2 method Config (deprecated)

Use method config.

It's the same usage like method config.

=head2 method STORE (deprecated)

Use method config.

Stores the language handle or options.

    # store the language handle
    $mt{L10N} = $lh;

    # store option of language handle
    $mt{numf_comma} = 1;
    # the same is:
    $lh->{numf_comma} = 1;

    # for debugging the HTML response
    $mt{nbsp} = 'see_position_of_nbsp_in_HTML_response'; # default is '&nbsp;'

    # Set a flag to say:
    # Substitute the whitespace before this flag and this flag
    # to no-break space
    # or to the debugging string.

    # The "nbsp_flag" is a string (1 or more characters).
    $mt{nbsp_flag} = "\N{UNIT SEPARATOR}";

=head2 method Keys (deprecated)

Use method config.

Get all keys back.

=head2 method Values (deprecated)

Use method config.

Get all values back.

=head2 method Get (deprecated)

Use method get_L10N, get_numf_comma, get_nbsp and/or get_nbsp_flag.

Submit 1 key or more.
The method Get give you the values back.

=head1 DIAGNOSTICS

All methods can croak at false parameters.

=head1 CONFIGURATION AND ENVIRONMENT

nothing

=head1 DEPENDENCIES

Carp

L<Params::Validate> Comfortable parameter validation

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<Locale::Maketext> Localisation framework

L<Tie::Hash>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2004-2008,
Steffen Winkler
C<< <steffenw@cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut