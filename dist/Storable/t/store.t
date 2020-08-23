#!./perl
#
#  Copyright (c) 1995-2000, Raphael Manfredi
#
#  You may redistribute only under the same terms as Perl 5, as specified
#  in the README file that comes with the distribution.
#


sub BEGIN {
    unshift @INC, 't';
    unshift @INC, 't/compat' if $] < 5.006002;
    no strict 'vars';
    require Config; Config->import;
    if ($ENV{PERL_CORE} and $Config{'extensions'} !~ /\bStorable\b/) {
        print "1..0 # Skip: Storable was not built\n";
        exit 0;
    }
    require 'st-dump.pl';
}

# $Storable::DEBUGME = 1;
use Storable qw(store retrieve store_fd nstore_fd fd_retrieve);

use Test::More tests => 25;

my $a = 'toto';
my $b = \$a;
my $c;
{ no strict 'subs'; $c = bless {}, CLASS; }
$c->{attribute} = 'attrval';
my %a = ('key', 'value', 1, 0, $a, $b, 'cvar', \$c);
my @a = ('first', undef, 3, -4, -3.14159, 456, 4.5,
	$b, \$a, $a, $c, \$c, \%a);

isnt(store(\@a, "store$$"), undef, 'store returned defined value');

my $dumped = &dump(\@a);
isnt($dumped, undef, 'dumped value is defined');

my $root = retrieve("store$$");
isnt($root, undef, 'retrieve returned defined value');

my $got = &dump($root);
isnt($got, undef, 'dumped value is defined');

is($got, $dumped, 'got expected value');

1 while unlink "store$$";

package FOO; our @ISA = qw(Storable);

sub make {
	my $self = bless {};
    no warnings 'once';
	$self->{key} = \%main::a;
	return $self;
};

package main;

my $foo = FOO->make;
isnt($foo->store("store$$"), undef, 'store returned defined value');

isnt(open(OUT, '>>', "store$$"), undef, 'open returned defined value');
binmode OUT;

no strict 'subs';
isnt(store_fd(\@a, '::OUT'), undef, 'store_fd returned defined value');
isnt(nstore_fd($foo, '::OUT'), undef, 'nstore_fd returned defined value');
isnt(nstore_fd(\%a, '::OUT'), undef, 'nstore_fd returned defined value');
use strict 'subs';

isnt(close(OUT), undef);

isnt(open(OUT, "store$$"), undef);

no strict 'subs';
my $r = fd_retrieve('::OUT');
use strict 'subs';
isnt($r, undef);
is(&dump($r), &dump($foo));

no strict 'subs';
$r = fd_retrieve('::OUT');
use strict 'subs';
isnt($r, undef);
is(&dump($r), &dump(\@a));

no strict 'subs';
$r = fd_retrieve('main::OUT');
use strict 'subs';
isnt($r, undef);
is(&dump($r), &dump($foo));

no strict 'subs';
$r = fd_retrieve('::OUT');
use strict 'subs';
isnt($r, undef);
is(&dump($r), &dump(\%a));

no strict 'subs';
eval { $r = fd_retrieve('::OUT'); };
use strict 'subs';
isnt($@, '');

{
    my %test = (
        old_retrieve_array => "\x70\x73\x74\x30\x01\x0a\x02\x02\x02\x02\x00\x3d\x08\x84\x08\x85\x08\x06\x04\x00\x00\x01\x1b",
        old_retrieve_hash  => "\x70\x73\x74\x30\x01\x0a\x03\x00\xe8\x03\x00\x00\x81\x00\x00\x00\x01\x61",
        retrieve_code      => "\x70\x73\x74\x30\x05\x0a\x19\xf0\x00\xff\xe8\x03\x1a\x0a\x0e\x01",
    );

    for my $k (sort keys %test) {
        open my $fh, '<', \$test{$k};
        eval { Storable::fd_retrieve($fh); };
        is($?, 0, 'RT 130098:  no segfault in Storable::fd_retrieve()');
    }
}

{

    my $frozen =
      "\x70\x73\x74\x30\x04\x0a\x08\x31\x32\x33\x34\x35\x36\x37\x38\x04\x08\x08\x08\x03\xff\x00\x00\x00\x19\x08\xff\x00\x00\x00\x08\x08\xf9\x16\x16\x13\x16\x10\x10\x10\xff\x15\x16\x16\x16\x1e\x16\x16\x16\x16\x16\x16\x16\x16\x16\x16\x13\xf0\x16\x16\x16\xfe\x16\x41\x41\x41\x41\xe8\x03\x41\x41\x41\x41\x41\x41\x41\x41\x51\x41\xa9\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xb8\xac\xac\xac\xac\xac\xac\xac\xac\x9a\xac\xac\xac\xac\xac\xac\xac\xac\xac\x93\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\x00\x64\xac\xa8\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\xac\x2c\xac\x41\x41\x41\x41\x41\x41\x41\x41\x41\x00\x80\x41\x80\x41\x41\x41\x41\x41\x41\x51\x41\xac\xac\xac";
    open my $fh, '<', \$frozen;
    eval { Storable::fd_retrieve($fh); };
    pass('RT 130635:  no stack smashing error when retrieving hook');

}

close OUT or die "Could not close: $!";
END { 1 while unlink "store$$" }
