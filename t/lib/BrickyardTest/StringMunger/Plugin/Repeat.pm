use 5.008;
use warnings;
use strict;

package BrickyardTest::StringMunger::Plugin::Repeat;
use Role::Basic 'with';
with qw(
    Brickyard::Role::Plugin
    BrickyardTest::StringMunger::Role::StringMunger
);

sub times {
    $_[0]->{times} = $_[1] if @_ == 2;
    $_[0]->{times};
}

sub run {
    my ($self, $text) = @_;
    $text x $self->times;
}
1;
