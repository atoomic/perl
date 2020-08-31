#!perl

# Test handling of XSUBs in pp_entersub

use Test::More tests => 1;
use XS::APItest;

my $sv = $_;
$sv = 0 unless defined $sv;
my $ref = XS::APItest::newRV($sv+1);
is \$$ref, $ref, 'XSUBs do not get to see PADTMPs';
