use 5.010;
use warnings;
use strict;

package Brickyard::Role::PluginBundle;
BEGIN {
  $Brickyard::Role::PluginBundle::VERSION = '1.111110';
}

# ABSTRACT: Role to use for plugin bundles
use Role::Basic allow => 'Brickyard::Accessor';
use Brickyard::Accessor new => 1, rw => [qw(brickyard)];
requires 'bundle_config';

sub _exp {
    my ($self, $package) = @_;
    $self->brickyard->expand_package($package);
}
1;


__END__
=pod

=head1 NAME

Brickyard::Role::PluginBundle - Role to use for plugin bundles

=head1 VERSION

version 1.111110

=head1 SYNOPSIS

    package My::App::PluginBundle::Foo;
    use Role::Basic 'with';
    with qw(Brickyard Role::Plugin);

    sub bundle_config {
        [
            [ '@Default/Uppercase', $_[0]->_exp('Uppercase'), {} ],
            [ '@Default/Repeat',    $_[0]->_exp('Repeat'), { times => 3 } ]
        ];
    }

=head1 METHODS

=head2 new

Constructs a new object. Takes an optional hash of arguments to initialize the
object.

=head2 brickyard

Read-write accessor for the L<Brickyard> object that created this object.

=head2 _exp

Takes a package name and delegates to the brickyard's C<expand_package()>
method.

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

