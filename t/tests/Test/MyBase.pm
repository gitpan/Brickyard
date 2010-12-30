use 5.008;
use strict;
use warnings;

package Test::MyBase;
# ABSTRACT: XXX

use parent 'Test::Class';

INIT { Test::Class->runtests }

sub make_object {
    my $test = shift;
    $test->class->new(@_);
}

1;
