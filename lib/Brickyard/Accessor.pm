use 5.010;
use warnings;
use strict;

package Brickyard::Accessor;
BEGIN {
  $Brickyard::Accessor::VERSION = '1.111080';
}

# ABSTRACT: Accessor generator for Brickyard classes

sub import {
    shift;
    my %args     = @_;
    my $pkg      = caller(0);
    my %key_ctor = (rw => \&_mk_accessors);
    for my $key (sort keys %key_ctor) {
        next unless $args{$key};
        die "value of the '$key' parameter should be an arrayref"
          unless ref $args{$key} eq 'ARRAY';
        $key_ctor{$key}->($pkg, @{ $args{$key} });
    }
    _mk_new($pkg) if $args{new};
    1;
}

sub _mk_new {
    my $pkg = shift;
    no strict 'refs';
    *{"${pkg}::new"} = sub {
        my $class = shift;
        bless {@_}, $class;
    };
}

sub _mk_accessors {
    my $pkg = shift;
    for my $n (@_) {
        no strict 'refs';
        *{"${pkg}::${n}"} = __make_rw($n);
    }
}

sub __make_rw {
    my $n = shift;
    sub {
        $_[0]->{$n} = $_[1] if @_ == 2;
        $_[0]->{$n};
    };
}
1;


__END__
=pod

=head1 NAME

Brickyard::Accessor - Accessor generator for Brickyard classes

=head1 VERSION

version 1.111080

=head1 SYNOPSIS

    package MyPackage;

    use Brickyard::Accessor (
        new => 1,
        rw  => [ qw(foo bar) ]
    );

=head1 DESCRIPTION

This module is based on L<Class::Accessor::Lite>, adapted to suit the needs of
L<Brickyard>.

=head1 THE USE STATEMENT

The use statement (i.e. the C<import> function) of the module takes a single
hash as an argument that specifies the types and the names of the properties.
It recognizes the following keys.

=over 4

=item C<new> => $true_or_false

Creates a default constructor if the value evaluates to true. Normally no
constructor is created. The constructor accepts a hash of arguments to
initialize a new object.

=item C<rw> => \@name_of_the_properties

Creates a scalar read-write accessor for the property names in the array
reference.

=back

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Brickyard>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/Brickyard/>.

The development version lives at L<http://github.com/hanekomu/Brickyard>
and may be cloned from L<git://github.com/hanekomu/Brickyard.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 AUTHOR

Marcel Gruenauer <marcel@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Marcel Gruenauer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

