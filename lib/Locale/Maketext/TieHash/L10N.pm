package Locale::Maketext::TieHash::L10N;

use 5.006001;
use strict;
use warnings;
use Carp qw(croak);

our $VERSION = '0.02';

require Tie::Hash;
our @ISA = qw(Tie::Hash);

sub TIEHASH {
  bless {nbsp => '&nbsp;'}, shift;
}

# store language handle or options
sub STORE {
  # Object, Key, Value
  my ($self, $key, $value) = @_;
  unless ($key) {
    croak 'key is not true';
  }
  elsif ($key =~ /^(?:L10N|nbsp|nbsp_flag)$/) {
    $key eq 'nbsp' and (defined $value or croak "key is 'nbsp', value is undef");
    $self->{$key} = $value;
  }
  elsif ($key eq 'numf_comma') {
    $self->{L10N}->{numf_comma} = $value;
  }
  else {
    croak "key is not 'L10N' or 'nbsp' or 'nbsp_flag' or 'numf_comma'";
  }
}

# translate
sub FETCH {
  # Object, Key
  my ($self, $key) = @_;
  local $_;
  eval {
    # Several parameters to maketext will submit as reference on an array.
    $_ = $self->{L10N}->maketext(ref $key eq 'ARRAY' ? @{$key} : $key);
  };
  $@ and croak $@;
  # By the translation the 'nbsp_flag' becomes blank put respectively behind one.
  # These so highlighted blanks are substituted after the translation into '&nbsp;'.
  if (defined $self->{nbsp_flag} and length $self->{nbsp_flag}) {
    s/ \Q$self->{nbsp_flag}\E/$self->{nbsp}/g;
  }
  $_;
}

# get all keys back
sub Keys {
  qw(L10N nbsp nbsp_flag);
}

# get all values back
sub Values {
  my $self = shift;
  ($self->{L10N}, $self->{nbsp}, $self->{nbsp_flag});
}

# get values
sub Get {
  my $self = shift;
  my @rv;
  for (@_) {
    $_ or croak "Get(undef) detected";
    /^(?:L10N|nbsp|nbsp_flag)$/ or croak "unknown '$_'";
    push @rv, $self->{$_};
  }
  return wantarray ? @rv : $rv[0];
}

1;
__END__

=head1 NAME

Locale::Maketext::TieHash::L10N - Tying language handle to a hash

=head1 SYNOPSIS

 use strict;
 use Locale::Maketext::TieHash::L10N;
 tie my %mt, 'Locale::Maketext::TieHash::L10N';
 { use MyProgram::L10N;
   my $lh = MyProgram::L10N->get_handle() || die "What language?";
   # store language handle
   $mt{L10N} = $lh;
 }
 # store option numf_comma
 $mt{numf_comma} = 1;
 ...
 print qq~$mt{Example}:\n$mt{["Can't open file [_1]: [_2].", $f, $!]}\n~;

=head2 The way without this module - You better see the difference.

 use strict;
 use MyProgram::L10N;
 my $lh = MyProgram::L10N->get_handle() || die "What language?";
 $lh{numf_comma} = 1;
 ...
 print $lh->maketext('Example') . ":\n" . $lh->maketext("Can't open file [_1]: [_2].", $f, $!) . "\n";

=head2 Example for writing HTML

 use strict;
 use Locale::Maketext::TieHash::L10N;
 tie my %mt, 'Locale::Maketext::TieHash::L10N';
 { use MyProgram::L10N;
   my $lh = MyProgram::L10N->get_handle() || die "What language?";
   # store language handle
   $mt{L10N} = $lh;
 }
 # store option numf_comma and set the nbsp_flag to '~';
 @mt{qw/numf_comma nbsp_flag/} = qw/1 ~/;
 # If you want to test your Script, you set "nbsp" on a string which you see in the Browser.
 $mt{nbsp} = '<span style="color:red">§</span>';
 ...
 # The browser shows value and unity always on a line.
 print qq#$mt{["Put [*,_1,~component,~components,no component] together, then have [*,_2,~piece,~pieces,no piece] of equipment.", $component, $piece]}\n#;

=head2 get the language handle C<">L10NC<">, C<">nbspC<"> and/or C<">nbsp_flagC<"> back

 # You can get the language handle "L10N", "nbsp" and/or "nbsp_flag" back on this way.
 my ($lh, $nbsp, $nbsp_flag) = tied(%mt)->Get(qw/L10N nbsp nbsp_flag/);
 # You can get the keys "L10N", "nbsp" and "nbsp_flag" back on this way.
 my @keys = tied(%mt)->Keys();
 # You can get the values of "L10N", "nbsp" and "nbsp_flag" back on this way.
 my @values = tied(%mt)->Values();
 # This is the way to store values of keys in another tyed hash like %mt.
 my %hash;
 @hash{tied(%mt)->Keys} = tied(%mt)->Values;

=head1 DESCRIPTION

Object methods like C<">maketextC<"> don't have interpreted into strings.
The module ties the language handle to a hash.
The object method C<">maketextC<"> is executed at fetch hash.
At long last this is the same, only the notation is shorter.

Sometimes the object method C<">maketextC<"> expects more than 1 parameter.
Then submit a reference on an array as hash key.

If you write HTML text with C<">Locale::MaketextC<">,
it then can happen that value and unity stand on separate lines.
The C<">nbsp_flagC<"> prevents the line break.
The C<">nbsp_flagC<"> per default is undef and this functionality is switched off.
Set your choice this value on a character string.
For switching the functionality off,
set the value to undef or a character string of the length 0.
C<">nbspC<"> per default is C<">&nbsp;C<">.

=head1 METHODS

=head2 TIEHASH

 use Locale::Maketext::TieHash::L10N;
 tie my %mt, 'Locale::Maketext::TieHash::L10N';

C<">TIEHASHC<"> ties your hash and set options defaults.

=head2 STORE

C<">STOREC<"> stores the language handle or options.

 # store the language handle
 $mt{L10N} = $lh;

 # store option of language handle
 $mt{numf_comma} = 1;
 # the same is:
 $lh->{numf_comma} = 1;

 # only for debugging your HTML response
 $mt{nbsp} = 'see_position_of_nbsp_in_HTML_response';   # default is '&nbsp;'
 
 # Set a flag to say:
 #  Substitute the whitespace before this flag and this flag to '&nbsp;' or your debugging string.
 # The "nbsp_flag" is a string (1 or more characters).
 $mt{nbsp_flag} = '~';

The method calls croak, if the key of your hash is undef or your key isn't correct
and if the value, you set to option C<">nbspC<">, is undef.

=head2 FETCH

C<">FETCHC<"> translate the given key of your hash and give back the translated string as value.

 # translation
 print $mt{'you write this language'};
 # the same is:
 print $lh->maketext('you write this language');
 ...
 print $mt{['Put [*,_1,component,components,no component] together.', $number]};
 # the same is:
 print $lh->maketext('Put [*,_1,component,components,no component] together.', $number);
 ...
 # Use "nbsp" and the "nbsp_flag" is true.
 print $mt{['Put [*,_1,~component,~components,no component] together.', $number]};
 # the same is:
 my $translation = $lh->maketext('Put [*,_1,~component,~components,no component] together.', $number);
 $tanslation =~ s/ ~/&nbsp;/g;   # But not a global debugging function is available.

The method calls croak, if the method C<">maketextC<"> of your stored language handle dies.

=head2 Keys

Get all keys back.

=head2 Values

Get all values back.

=head2 Get

Submit 1 key or more. The method C<">GetC<"> give you the values back.

The method calls croak if a key is undef or unknown.

=head1 SEE ALSO

Tie::Hash

Locale::Maketext

=head1 AUTHOR

Steffen Winkler, E<lt>cpan@steffen-winkler.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004, 2005 by Steffen Winkler

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.6.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
