#!./perl -Tw

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require Config;
    if (($Config::Config{'extensions'} !~ m!\bList/Util\b!) ){
        print "1..0 # Skip -- Perl configured without List::Util module\n";
        exit 0;
    }
}

# symbolic references used later
use strict qw( vars subs );
use Data::Dumper;

# @DB::dbline values have both integer and string components (Benjamin Goldberg)
use Scalar::Util qw( dualvar );
my $dualfalse = dualvar(0, 'false');
my $dualtrue = dualvar(1, 'true');

use Test::More qw(no_plan); # tests => 106;

# must happen at compile time for DB:: package variable localizations to work
BEGIN {
        use_ok( 'DB' );
}

# test DB::DB()
{ 
        ok( ! defined DB::DB(), 
                'DB::DB() should return undef if $DB::ready is false');
        is( DB::catch(), 1, 'DB::catch() should work' );
        is( DB->skippkg('foo'), 1, 'DB->skippkg() should push args' );

        # change packages to mess with caller()
        package foo;
        ::ok( ! defined DB::DB(), 'DB::DB() should skip skippable packages' );

        package main;
        is( $DB::filename, $0, '... should set $DB::filename' );
        is( $DB::lineno, __LINE__ - 4, '... should set $DB::lineno' );

        DB::DB();
        # stops at line 94
}


# test DB::files()
{
        my $dbf = () = DB::files();
my @temp = DB::files();
for (@temp[0..4]) { if (length $_) { print "AAA: $_\n"; } }
@temp = grep { /\.pm/ } keys %main::;
for (@temp[0..4]) { if (length $_) { print "BBB: $_\n"; } }
        my $main = () = grep ( m!^_<!, keys %main:: );
print "CCC: $main\n";
        is( $dbf, $main, 'DB::files() should pick up filenames from %main::' );
}

# test DB::lines()
{
        local @DB::dbline = ( 'foo' );
        is( DB->lines->[0], 'foo', 'DB::lines() should return ref to @DB::dbline' );
}

# test DB::loadfile()
#SKIP: {
{
print "WWW: $_\n" for @DB::dbline;
        local (*DB::dbline, $DB::filename);
print "XXX: $DB::filename\n";
print Dumper \*DB::dbline;
        ok( ! defined DB->loadfile('notafile'),
                'DB::loadfile() should not find unloaded file' );
my @temp = grep { /\.pm/ } keys %main::;
for (@temp[0..4]) { if (length $_) { print "YYY: $_\n"; } }
        my $file = (grep { m|^_<.+\.pm| } keys %main:: )[0];
        ok($file, "Can identify loaded file");
        $file =~ s/^_<..//;

        my $db = DB->loadfile($file);
        like( $db, qr!$file\z!, '... should find loaded file from partial name');

        no strict 'refs';
        is( *DB::dbline, *{ "_<$db" } , 
                '... should set *DB::dbline to associated glob');
        is( $DB::filename, $db, '... should set $DB::filename to file name' );

        # test clients
}

