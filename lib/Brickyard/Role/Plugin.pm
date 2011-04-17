use 5.010;
use warnings;
use strict;

package Brickyard::Role::Plugin;
BEGIN {
  $Brickyard::Role::Plugin::VERSION = '1.111070';
}

# ABSTRACT: Role to use for plugins
use Role::Basic 0.12 allow => 'Brickyard::Accessor';
use Brickyard::Accessor new => 1, rw => [qw(brickyard name)];

sub plugins_with {
    my ($self, $role) = @_;
    $self->brickyard->plugins_with($role);
}

sub normalize_param {
    my ($self, $param) = @_;
    return [] unless defined $param;
    if (wantarray) {
        return ref $param eq 'ARRAY' ? @$param : $param;
    } else {
        return ref $param eq 'ARRAY' ? $param : [ $param ];
    }
}

1;


__END__
=pod

=head1 NAME

Brickyard::Role::Plugin - Role to use for plugins

=head1 VERSION

version 1.111070

=head1 SYNOPSIS

    package My::App::Plugin::Foo;
    use Role::Basic 'with';
    with qw(Brickyard Role::Plugin);

=head1 METHODS

=head2 new

Constructs a new object. Takes an optional hash of arguments to initialize the
object.

=head2 brickyard

Read-write accessor for the L<Brickyard> object that created this plugin.

=head2 name

Read-write accessor for the plugin's name.

=head2 plugins_with

Delegates to the brickyard object's C<plugins_with()> method.

=head2 normalize_param

Utility method to get a parameter value. It returns the parameter with
the given name so it's ready to be used as a list. It's returned as a
list in list context and as a reference to a list in scalar context.

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

