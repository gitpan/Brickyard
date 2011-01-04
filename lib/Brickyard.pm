use 5.008;
use warnings;
use strict;

package Brickyard;
BEGIN {
  $Brickyard::VERSION = '1.110040';
}

# ABSTRACT: Plugin system based on roles
use Brickyard::Accessor rw => [qw(base_package plugins plugins_role_cache)];

sub new {
    my $class = shift;
    bless {
        base_package       => 'MyApp',
        plugins            => [],
        plugins_role_cache => {},
        @_
    }, $class;
}

sub plugins_with {
    my ($self, $role) = @_;
    $role = $self->expand_package($role);
    $self->plugins_role_cache->{$role} ||=
      [ grep { $_->DOES($role) } @{ $self->plugins } ];
    @{ $self->plugins_role_cache->{$role} };
}

sub reset_plugins {
    my $self = shift;
    $self->plugins([]);
    $self->plugins_role_cache({});
}

sub parse_ini {
    my ($self, $ini) = @_;
    my @result = ([ '_', $self->expand_package('_'), {} ]);
    my $counter = 0;
    foreach (split /(?:\015{1,2}\012|\015|\012)/, $ini) {
        $counter++;
        next if /^\s*(?:\#|\;|$)/;    # Skip comments and empty lines
        s/\s\;\s.+$//g;               # Remove inline comments

        # Handle section headers
        if (/^\s*\[\s*(.+?)\s*\]\s*$/) {
            push @result, [ $1, $self->expand_package($1), {} ];
            next;
        }

        # Handle properties
        if (/^\s*([^=]+?)\s*=\s*(.*?)\s*$/) {
            my $section = $result[-1][2];

            # if a property is seen multiple times, it becomes an array
            if (exists $section->{$1}) {
                $section->{$1} = [ $section->{$1} ]
                  unless ref $section->{$1} eq 'ARRAY';
                push @{ $section->{$1} } => $2;
            } else {
                $section->{$1} = $2;
            }
            next;
        }
        die "Syntax error at line $counter: '$_'";
    }
    \@result;
}

sub expand_package {
    my $self = shift;
    local $_ = shift;
    my $base = s/^\*// ? 'Brickyard' : $self->base_package;
    return $_ if s/^@/$base\::PluginBundle::/;
    return $_ if s/^-/$base\::Role::/;
    return $_ if s/^=//;
    "$base\::Plugin::$_";
}

sub init_from_config {
    my ($self, $config, $root) = @_;
    unless (ref $config) {
        $config = $self->parse_ini(
            do { local (@ARGV, $/) = $config; <> }
        );
    }

    for my $section (@$config) {
        my ($name, $package, $plugin_config) = @$section;
        if ($name eq '_') {

            # Global container configuration
            while (my ($key, $value) = each %$plugin_config) {
                $root->$key($value);
            }
        } else {
            eval "require $package";
            die "Cannot require $package: $@" if $@;
            if ($package->DOES('Brickyard::Role::PluginBundle')) {
                my $bundle = $package->new(brickyard => $self, %$plugin_config);
                $self->init_from_config($bundle->bundle_config, $root);
            } else {
                push @{ $self->plugins } => $package->new(
                    name      => $name,
                    brickyard => $self,
                    %$plugin_config
                );
            }
        }
    }
}

1;


__END__
=pod

=head1 NAME

Brickyard - Plugin system based on roles

=head1 VERSION

version 1.110040

=head1 SYNOPSIS

    use Brickyard;
    my $brickyard = Brickyard->new(base_package => 'My::App');
    my $root_config = MyApp::RootConfig->new;
    $brickyard->init_from_config('myapp.ini', $root_config);
    $_->some_method for $brickyard->plugins_with(-SomeRole);

=head1 DESCRIPTION

This is a lightweight plugin system based on roles. It does not use Moose but
relies on C<Role::Basic> instead, and very few other modules.

It takes its inspiration from L<Dist::Zilla>, but has much less flexibility
and therefore is also much less complex.

=head1 METHODS

=head2 new

Constructs a new object. Takes an optional hash of arguments to initialize the
object.

=head2 base_package

Read-write accessor for the base package name that is used in
C<expand_package()>. Defaults to C<MyApp>.

=head2 parse_ini

Takes a string that contains configuration in C<INI> format and parses it into
an array of configuration sections. It returns a reference to that array.

Using an array, as opposed to a hash, ensures that the section order is
preserved, so we know in which order to process plugins in L<Brickyard>'s
C<plugins_with()> method.

Each array element corresponds to an C<INI> section. Each section is itself a
reference to an array with three elements:

The first element is the section name. The second element is the package name
of the plugin; it is obtained by expanding the section name using
C<expand_package()>. The third element is a reference to a plugin
configuration hash; it is the section's payload. If a section payload key
occurs several times, it is turned into an array reference in the plugin
configuration hash.

The first section is the global section, denoted by the name C<_>. Any payload
in the C<INI> configuration that occurs before the first section ends up in
this section.

For example:

    ; A comment
    name = Foobar

    [@Default]

    [Some::Thing]
    foo = bar
    baz = 43
    baz = blah

is parsed into this structure:

    [ '_',        'MyApp::Plugin::_',             { name => 'Foobar' } ],
    [ '@Default', 'MyApp::PluginBundle::Default', {} ],
    [   'Some::Thing',
        'MyApp::Plugin::Some::Thing',
        {   'baz' => [ '43', 'blah' ],
            'foo' => 'bar'
        }
    ]

=head2 expand_package

Takes an abbreviated package name and expands it into the real package name.
C<INI> section names are processed this way so you don't have to repeat common
prefixes all the time.

If C<@> occurs at the start of the string, it is replaced by the base name
plus <::PluginBundle::>.

A C<-> is replaced by the base name plus C<::Role::>.

A C<=> is replaced by the empty string, so the remained is returned unaltered.

Otherwise the base name plus C<::Plugin::> is prepended.

The base name is normally whatever C<base_package()> returns, but if the
string starts with C<*>, the asterisk is deleted and C<Brickyard> is used for
the base name.

Here are some examples of package name expansion:

    @Service::Default     MyApp::PluginBundle::Service::Default
    *@Filter              Brickyard::PluginBundle::Filter
    *Filter               Brickyard::Plugin::Filter
    =Foo::Bar             Foo::Bar
    Some::Thing           MyApp::Plugin::Some::Thing
    -Thing::Frobnulizer   MyApp::Role::Thing::Frobnulizer

=head2 init_from_config

Takes configuration and a root object. For each configuration section it
creates a plugin object, initializes it with the plugin configuration hash and
adds it to the brickyard's array of plugins.

Any configuration keys that appear in the configuration's root section are set
on the root object. So the root object can be anything that has set-accessors
for all the configuration keys that can appear in the configuration's root
section.

If the configuration is a string in C<INI> format, it is parsed. It can also
be a configuration structure as returned by C<parse_ini()> or a plugin
bundle's C<bundle_config()> method.

If an object is created that consumes the L<Brickyard::Role::PluginBundle>
role, the bundle is processed recursively.

=head2 plugins

Read-write accessor for the reference to an array of plugins.

=head2 plugins_with

Takes a role name and returns a list of all the plugins that consume this
role. The result is cached, keyed by the role name.

=head2 reset_plugins

Clears the array of plugins as well as the cache - see C<plugins_with()>.

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

