#!/usr/bin/env perl
use warnings;
use strict;
use lib 't/lib';
use Brickyard;
use Test::More;
my $brickyard = Brickyard->new(base_package => 'BrickyardTest::StringMunger');
my $plugins =
  $brickyard->get_container_from_config('t/config/string-munger.ini');
my $text = 'hello';
$text = $_->run($text) for $plugins->plugins_with(-StringMunger);
is $text, 'HELLOHELLOHELLO', 'munge string with string-munger.ini';

$plugins->reset_cache;
$plugins =
  $brickyard->get_container_from_config('t/config/string-munger-filter.ini');
$text = 'hello';
$text = $_->run($text) for $plugins->plugins_with(-StringMunger);
is $text, 'hellohellohello', 'munge string with string-munger-filter.ini';
done_testing();