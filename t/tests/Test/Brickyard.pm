use 5.008;
use strict;
use warnings;

package Test::Brickyard;

# ABSTRACT: Class tests for Brickyard
use Test::Most;
use Brickyard;
use parent 'Test::MyBase';
sub class { 'Brickyard' }

sub constructor : Test(2) {
    my $test = shift;
    my $obj  = $test->make_object;
    isa_ok $obj, $test->class;
    is $obj->base_package, 'MyApp', 'default base_package';
}

sub set_base_package : Test(1) {
    my $test = shift;
    my $obj = $test->make_object(base_package => 'Foobar');
    is $obj->base_package, 'Foobar', 'set base_package on constructor';
}

sub expand_package : Test(6) {
    my $test = shift;
    my $obj  = $test->make_object;
    is $obj->expand_package('@Service::Default'),
      'MyApp::PluginBundle::Service::Default',
      'expand [@Default]';
    is $obj->expand_package('*@Filter'), 'Brickyard::PluginBundle::Filter',
      'expand [*@Filter]';
    is $obj->expand_package('*Filter'), 'Brickyard::Plugin::Filter',
      'expand [*Filter]';
    is $obj->expand_package('=Foo::Bar'), 'Foo::Bar', 'expand [=Foo::Bar]';
    is $obj->expand_package('Some::Thing'), 'MyApp::Plugin::Some::Thing',
      'expand [Some::Thing]';
    is $obj->expand_package('-Thing::Frobnulizer'),
      'MyApp::Role::Thing::Frobnulizer', 'expand [-Thing::Frobnulizer]';
}

sub parse_ini : Test(1) {
    my $test = shift;
    my $ini  = <<'EOINI';
; A comment
name = Foobar

[@Default]

[Some::Thing]
foo = bar
baz = 43
baz = blah
EOINI
    my $config = $test->make_object->parse_ini($ini);
    eq_or_diff $config,
      [ [ '_',        'MyApp::Plugin::_',             { name => 'Foobar' } ],
        [ '@Default', 'MyApp::PluginBundle::Default', {} ],
        [   'Some::Thing',
            'MyApp::Plugin::Some::Thing',
            {   'baz' => [ '43', 'blah' ],
                'foo' => 'bar'
            }
        ]
      ],
      'parsed config';
}
1;
