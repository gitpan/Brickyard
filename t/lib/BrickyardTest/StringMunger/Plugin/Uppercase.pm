use 5.008;
use warnings;
use strict;

package BrickyardTest::StringMunger::Plugin::Uppercase;
use Role::Basic 'with';
with qw(
    Brickyard::Role::Plugin
    BrickyardTest::StringMunger::Role::StringMunger
);

sub run {
    my ($self, $text) = @_;
    uc $text;
}

1;
