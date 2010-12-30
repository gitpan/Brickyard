use 5.008;
use warnings;
use strict;

package BrickyardTest::StringMunger::PluginBundle::Default;
use Role::Basic 'with';
with 'Brickyard::Role::PluginBundle';

sub bundle_config {
    [
        [ '@Default/Uppercase', $_[0]->_exp('Uppercase'), {} ],
        [ '@Default/Repeat',    $_[0]->_exp('Repeat'), { times => 3 } ],
    ];
}

1;
