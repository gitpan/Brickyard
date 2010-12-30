#!/usr/bin/env perl
use warnings;
use strict;
use lib 't/lib';
use Brickyard;
use Test::More;
my $brickyard = Brickyard->new(base_package => 'BrickyardTest::StringMunger');
my $plugins =
  $brickyard->get_container_from_config('t/config/string_munger.ini');
my $text = 'hello';
$text = $_->run($text) for $plugins->plugins_with(-StringMunger);
is $text, 'HELLOHELLOHELLO', 'munged string';
done_testing();
