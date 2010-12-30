use 5.008;
use warnings;
use strict;

package Brickyard::PluginContainer;
BEGIN {
  $Brickyard::PluginContainer::VERSION = '1.103640';
}

# ABSTRACT: Container for plugins
sub new {
    my $class = shift;
    bless {
        plugins => [],
        (@_ == 1 && ref($_[0]) eq 'HASH' ? %{ $_[0] } : @_),
    }, $class;
}

sub brickyard {
    $_[0]->{brickyard} = $_[1] if @_ == 2;
    $_[0]->{brickyard};
}

sub plugins {
    $_[0]->{plugins} = $_[1] if @_ == 2;
    $_[0]->{plugins};
}

sub plugins_with {
    my ($self, $role) = @_;
    $role = $self->brickyard->expand_package($role);
    our %plugins_role_cache;
    $plugins_role_cache{$role} ||=
      [ grep { $_->DOES($role) } @{ $self->plugins } ];
    @{ $plugins_role_cache{$role} };
}
1;


__END__
=pod

=head1 NAME

Brickyard::PluginContainer - Container for plugins

=head1 VERSION

version 1.103640

=head1 SYNOPSIS

    use Brickyard;
    my $brickyard = Brickyard->new(base_package => 'My::App');
    my $plugins =
      $brickyard->get_container_from_config('myapp.ini');
    $_->some_method for $plugins->plugins_with(-SomeRole);

=head1 METHODS

=head2 new

Constructs a new object. Takes an optional hash or hash reference of arguments
to initialize the object.

=head2 brickyard

Read-write accessor for the L<Brickyard> object that populated this container.

=head2 plugins

Read-write accessor for the reference to an array of plugins.

=head2 plugins_with

Takes a role name and returns a list of all the plugins that consume this
role.

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

The development version lives at L<http://github.com/hanekomu/Brickyard.git>
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

