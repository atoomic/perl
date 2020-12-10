#!./perl

BEGIN {
    chdir 't' if -d 't';
    require './test.pl';
    set_up_inc(  qw(. ../lib) );
}
plan tests => 319;

my $list_assignment_supported = 1;

#mg.c says list assignment not supported on VMS and SYMBIAN.
$list_assignment_supported = 0 if ($^O eq 'VMS');

my %msg = (
    'durl'  => 'during localization',
    'outl'  => 'outside of localization',
    'ges'   => 'got expected string',
    'geax'  => 'got expected array expansion',
    'geae'  => 'got expected array element',
    'gehe'  => 'got expected hash element',
    'aend'  => 'array element not defined',
    'aenld' => 'array element no longer defined',
    'aenx'  => 'array element does not exist',
    'genae' => 'got expected number of array elements',
    'genhe' => 'got expected number of hash elements',
    'henx'  => 'hash element does not exist',
    'vnde'  => 'variable is not defined, as expected',
);

our ($alpha, $beta, $c, $d);
our ($x, $y);
sub foo {
    local($alpha, $beta) = @_;
    local($c, $d);
    $c = "c 3";
    $d = "d 4";
    { local($alpha,$c) = ("a 9", "c 10"); ($x, $y) = ($alpha, $c); }
    is($alpha, "a 1", "$msg{durl}, $msg{ges}");
    is($beta, "b 2", "$msg{durl}, $msg{ges}");
    $c, $d;
}

$alpha = "a 5";
$beta = "b 6";
$c = "c 7";
$d = "d 8";

my @res;
@res =  &foo("a 1","b 2");
is($res[0], "c 3", "$msg{outl}, $msg{ges}");
is($res[1], "d 4", "$msg{outl}, $msg{ges}");

is($alpha, "a 5", "$msg{outl}, $msg{ges}");
is($beta, "b 6", "$msg{outl}, $msg{ges}");
is($c, "c 7", "$msg{outl}, $msg{ges}");
is($d, "d 8", "$msg{outl}, $msg{ges}");
is($x, "a 9", "$msg{outl}, $msg{ges}");
is($y, "c 10", "$msg{outl}, $msg{ges}");

# same thing, only with arrays and associative arrays

note("arrays and associative arrays");
our (@b, @c, %d);
sub foo2 {
    local($alpha, @b) = @_;
    local(@c, %d);
    @c = "c 3";
    $d{''} = "d 4";
    { local($alpha,@c) = ("a 19", "c 20"); ($x, $y) = ($alpha, @c); }
    is($alpha, "a 1", "$msg{durl}, $msg{ges}");
    is("@b", "b 2", "$msg{durl}, $msg{geax}");
    $c[0], $d{''};
}

$alpha = "a 5";
@b = "b 6";
@c = "c 7";
$d{''} = "d 8";

@res = &foo2("a 1","b 2");
is($res[0], "c 3", "$msg{outl}, $msg{ges}");
is($res[1], "d 4", "$msg{outl}, $msg{ges}");

is($alpha, "a 5", "$msg{outl}, $msg{ges}");
is("@b", "b 6", "$msg{outl}, $msg{geax}");
is($c[0], "c 7", "$msg{outl}, $msg{geae}");
is($d{''}, "d 8", "$msg{outl}, $msg{gehe}");
is($x, "a 19",
    "$msg{outl}, $msg{ges} (global assigned $msg{durl})");
is($y, "c 20",
    "$msg{outl}, $msg{ges} (global assigned $msg{durl})");


our ($e);
eval 'local($$e)';
like($@, qr/Can't localize through a reference/, "Can't localize through a reference");

eval '$e = []; local(@$e)';
like($@, qr/Can't localize through a reference/, "Can't localize through a reference");

eval '$e = {}; local(%$e)';
like($@, qr/Can't localize through a reference/, "Can't localize through a reference");

note("Array and hash elements");

our @a = ('a', 'b', 'c');
{
    local($a[1]) = 'foo';
    local($a[2]) = $a[2];
    is($a[1], 'foo', "$msg{durl}, array, $msg{geae}");
    is($a[2], 'c', "$msg{durl}, array, $msg{geae}");
    undef @a;
}
is($a[1], 'b', "$msg{outl}, $msg{geae}");
is($a[2], 'c', "$msg{outl}, $msg{geae}");
ok(!defined $a[0], "$msg{outl}, $msg{aenld}");

@a = ('a', 'b', 'c');
{
    local($a[4]) = 'x';
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'x', "$msg{durl}, array, $msg{geae}");
}
is(scalar(@a), 3, "$msg{outl}, $msg{genae}");
ok(!exists $a[3], "$msg{outl}, $msg{aend}");
ok(!exists $a[4], "$msg{outl}, $msg{aend}");

@a = ('a', 'b', 'c');
{
    local($a[5]) = 'z';
    $a[4] = 'y';
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'y', "$msg{durl}, array, $msg{geae}");
    is($a[5], 'z', "$msg{durl}, array, $msg{geae}");
}
is(scalar(@a), 5, "$msg{outl}, $msg{genae}");
ok(!defined $a[3], "$msg{outl}, $msg{aend}");
is($a[4], 'y', "$msg{outl}, $msg{geae}");
ok(!exists $a[5], "$msg{outl}, $msg{aenx}");

@a = ('a', 'b', 'c');
{
    local(@a[4,6]) = ('x', 'z');
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'x', "$msg{durl}, array, $msg{geae}");
    ok(!defined $a[5], "$msg{durl}, $msg{aend}");
    is($a[6], 'z', "$msg{durl}, array, $msg{geae}");
}
is(scalar(@a), 3, "$msg{outl}, $msg{genae}");
ok(!exists $a[3], "$msg{outl}, $msg{aenx}");
ok(!exists $a[4], "$msg{outl}, $msg{aenx}");
ok(!exists $a[5], "$msg{outl}, $msg{aenx}");
ok(!exists $a[6], "$msg{outl}, $msg{aenx}");

@a = ('a', 'b', 'c');
{
    local(@a[4,6]) = ('x', 'z');
    $a[5] = 'y';
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'x', "$msg{durl}, array, $msg{geae}");
    is($a[5], 'y', "$msg{durl}, array, $msg{geae}");
    is($a[6], 'z', "$msg{durl}, array, $msg{geae}");
}
is(scalar(@a), 6, "$msg{outl}, $msg{genae}");
ok(!defined $a[3], "$msg{outl}, $msg{aend}");
ok(!defined $a[4], "$msg{outl}, $msg{aend}");
is($a[5], 'y', "$msg{outl}, $msg{geae}");
ok(!exists $a[6], "$msg{outl}, $msg{aenx}");

@a = ('a', 'b', 'c');
{
    local($a[1]) = "X";
    shift @a;
}
is($a[0].$a[1], "Xb", "shift off global array $msg{durl} leaves expected elements");
{
    my $d = "@a";
    local @a = @a;
    is("@a", $d, "$msg{durl}, $msg{geax}");
}

@a = ('a', 'b', 'c');
$a[4] = 'd';
{
    delete local $a[1];
    is(scalar(@a), 5, "$msg{durl}, $msg{genae}");
    is($a[0], 'a', "$msg{durl}, array, $msg{geae}");
    ok(!exists($a[1]), "$msg{durl}, array, $msg{aenx}");
    is($a[2], 'c', "$msg{durl}, array, $msg{geae}");
    ok(!exists($a[3]), "$msg{durl}, array, $msg{aenx}");
    is($a[4], 'd', "$msg{durl}, array, $msg{geae}");

    ok(!exists($a[888]), "$msg{durl}, $msg{aenx}");
    delete local $a[888];
    is(scalar(@a), 5, "$msg{durl}, $msg{genae}");
    ok(!exists($a[888]), "$msg{durl}, $msg{aenx}");

    ok(!exists($a[999]), "$msg{durl}, $msg{aenx}");
    my ($d, $zzz) = delete local @a[4, 999];
    is(scalar(@a), 3, "$msg{durl}, $msg{genae}");
    ok(!exists($a[4]), "$msg{durl}, $msg{aenx}");
    ok(!exists($a[999]), "$msg{durl}, $msg{aenx}");
    is($d, 'd', "got string assigned to $msg{durl}");
    is($zzz, undef, "variable undefined as expected");

    my $c = delete local $a[2];
    is(scalar(@a), 1, "$msg{durl}, $msg{genhe}");
    ok(!exists($a[2]), "$msg{durl}, $msg{aenx}");
    is($c, 'c', "got string assigned to from delete hash element");

    $a[888] = 'yyy';
    $a[999] = 'zzz';
}
is(scalar(@a), 5, "$msg{outl}, $msg{genae}");
is($a[0], 'a', "$msg{outl}, $msg{geae}");
is($a[1], 'b', "$msg{outl}, $msg{geae}");
is($a[2], 'c', "$msg{outl}, $msg{geae}");
ok(!defined($a[3]), "$msg{outl}, $msg{aend}");
is($a[4], 'd', "$msg{outl}, $msg{geae}");
ok(!exists($a[5]), "$msg{outl}, $msg{aenx}");
ok(!exists($a[888]), "$msg{outl}, $msg{aenx}");
ok(!exists($a[999]), "$msg{outl}, $msg{aenx}");

our %h = (a => 1, b => 2, c => 3, d => 4);
{
    delete local $h{b};
    is(scalar(keys(%h)), 3, "$msg{durl}, $msg{genhe}");
    is($h{a}, 1, "$msg{durl}, $msg{gehe}");
    ok(!exists($h{b}), "$msg{durl}, $msg{henx}");
    is($h{c}, 3, "$msg{durl}, $msg{gehe}");
    is($h{d}, 4, "$msg{durl}, $msg{gehe}");

    ok(!exists($h{yyy}), "$msg{henx}");
    delete local $h{yyy};
    is(scalar(keys(%h)), 3, "$msg{durl}, $msg{genhe}");
    ok(!exists($h{yyy}), "$msg{durl}, $msg{henx}");

    ok(!exists($h{zzz}), "$msg{henx}");
    my ($d, $zzz) = delete local @h{qw/d zzz/};
    is(scalar(keys(%h)), 2, "$msg{durl}, $msg{genhe}");
    ok(!exists($h{d}), "$msg{durl}, $msg{henx}");
    ok(!exists($h{zzz}), "$msg{durl}, $msg{henx}");
    is($d, 4, "got string assigned to from delete hash element");
    is($zzz, undef, $msg{vnde});

    my $c = delete local $h{c};
    is(scalar(keys(%h)), 1, "$msg{durl}, $msg{genhe}");
    ok(!exists($h{c}), "$msg{durl}, $msg{henx}");
    is($c, 3, "got string assigned to from delete hash element");

    $h{yyy} = 888;
    $h{zzz} = 999;
}
is(scalar(keys(%h)), 4, "$msg{outl}, $msg{genhe}");
is($h{a}, 1, "$msg{outl}, $msg{gehe}");
is($h{b}, 2, "$msg{outl}, $msg{gehe}");
is($h{c}, 3, "$msg{outl}, $msg{gehe}");
is($h{d}, 4, "$msg{outl}, $msg{gehe}");
ok(!exists($h{yyy}), "$msg{outl}, $msg{henx}");
ok(!exists($h{zzz}), "$msg{outl}, $msg{henx}");

%h = ('a' => { 'b' => 1 }, 'c' => 2);
{
    my $a = delete local $h{a};
    is(scalar(keys(%h)), 1, "$msg{durl}, $msg{genhe}");
    ok(!exists($h{a}), "$msg{durl}, $msg{henx}");
    is($h{c}, 2, "$msg{durl}, $msg{gehe}");
    is(scalar(keys(%$a)), 1, "$msg{durl}, $msg{genhe}");

    my $b = delete local $a->{b};
    is(scalar(keys(%$a)), 0, "$msg{durl}, $msg{genhe}");
    is($b, 1, "$msg{durl}, $msg{gehe}");

    $a->{d} = 3;
}
is(scalar(keys(%h)), 2, "$msg{outl}, $msg{genhe}");
{
    my $a = $h{a};
    is(scalar(keys(%$a)), 2, "$msg{genhe}");
    is($a->{b}, 1, "$msg{gehe}");
    is($a->{d}, 3, "$msg{gehe}");
}
is($h{c}, 2, "$msg{outl}, $msg{gehe}");

%h = ('a' => 1, 'b' => 2, 'c' => 3);
{
    local($h{'a'}) = 'foo';
    local($h{'b'}) = $h{'b'};
    is($h{'a'}, 'foo', "$msg{durl}, $msg{gehe}");
    is($h{'b'}, 2, "$msg{durl}, $msg{gehe}");
    local($h{'c'});
    delete $h{'c'};
}
is($h{'a'}, 1, "$msg{outl}, $msg{gehe}");
is($h{'b'}, 2, "$msg{outl}, $msg{gehe}");
{
    my $d = join("\n", map { "$_=>$h{$_}" } sort keys %h);
    local %h = %h;
    is(join("\n", map { "$_=>$h{$_}" } sort keys %h), $d,
        "got expected result of sort, map, join");
}
is($h{'c'}, 3, "$msg{outl}, $msg{genhe}");

note("check for scope leakage");

$alpha = 'outer';
if (1) { local $alpha = 'inner' }
is($alpha, 'outer', 'no scope leakage');

note("see if localization works when scope unwinds");

our $m;
local $m = 5;
eval {
    for $m (6) {
        local $m = 7;
        die "bye";
    }
};
is($m, 5, "localization works after scope unwinds");

note("see if localization works on tied arrays");
{
    package TA;
    sub TIEARRAY { bless [], $_[0] }
    sub STORE { print "# STORE [@_]\n"; $_[0]->[$_[1]] = $_[2] }
    sub FETCH { no warnings 'uninitialized'; my $v = $_[0]->[$_[1]]; print "# FETCH [@_=$v]\n"; $v }
    sub EXISTS { print "# EXISTS [@_]\n"; exists $_[0]->[$_[1]]; }
    sub DELETE { print "# DELETE [@_]\n"; delete $_[0]->[$_[1]]; }
    sub CLEAR { print "# CLEAR [@_]\n"; @{$_[0]} = (); }
    sub FETCHSIZE { scalar(@{$_[0]}) }
    sub SHIFT { shift (@{$_[0]}) }
    sub EXTEND {}
}

tie @a, 'TA';
@a = ('a', 'b', 'c');
{
    local($a[1]) = 'foo';
    local($a[2]) = $a[2];
    is($a[1], 'foo', "$msg{durl}, $msg{geae}");
    is($a[2], 'c', "$msg{durl}, $msg{geae}");
    @a = ();
}
is($a[1], 'b', "$msg{outl}, $msg{geae}");
is($a[2], 'c', "$msg{outl}, $msg{geae}");
ok(!defined $a[0], "$msg{outl}, $msg{aenld}");
{
    no warnings 'uninitialized';
    my $d = "@a";
    local @a = @a;
    is("@a", $d, "$msg{durl}, $msg{geax}");
}
note("RT #7938 (GH #4611): localising an array should make it temporarily untied");
{
    @a = qw(a b c);
    local @a = (6,7,8);
    is("@a", "6 7 8", 'local @a assigned 6,7,8');
    {
        my $c = 0;
        no warnings 'redefine';
        local *TA::STORE = sub { $c++ };
        $a[0] = 9;
        is($c, 0, 'STORE not called after array localised');
    }
    is("@a", "9 7 8", 'local @a should now be 9 7 8');
}
is("@a", "a b c", '@a should now contain original value');


note("local() should preserve the existenceness of tied array elements");
@a = ('a', 'b', 'c');
{
    local($a[4]) = 'x';
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'x', "$msg{durl}, $msg{geae}");
}
is(scalar(@a), 3, "$msg{outl}, $msg{genae}");
ok(!exists $a[3], "$msg{outl}, $msg{aend}");
ok(!exists $a[4], "$msg{outl}, $msg{aend}");

@a = ('a', 'b', 'c');
{
    local($a[5]) = 'z';
    $a[4] = 'y';
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'y', "$msg{durl}, $msg{geae}");
    is($a[5], 'z', "$msg{durl}, $msg{geae}");
}
is(scalar(@a), 5, "$msg{outl}, $msg{genae}");
ok(!defined $a[3], "$msg{outl}, $msg{aend}");
is($a[4], 'y', "$msg{outl}, $msg{geae}");
ok(!exists $a[5], "$msg{outl}, $msg{aenx}");

@a = ('a', 'b', 'c');
{
    local(@a[4,6]) = ('x', 'z');
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'x', "$msg{durl}, $msg{geae}");
    ok(!defined $a[5], "$msg{durl}, $msg{aend}");
    is($a[6], 'z', "$msg{durl}, $msg{geae}");
}
is(scalar(@a), 3, "$msg{outl}, $msg{genae}");
ok(!exists $a[3], "$msg{outl}, $msg{aenx}");
ok(!exists $a[4], "$msg{outl}, $msg{aenx}");
ok(!exists $a[5], "$msg{outl}, $msg{aenx}");
ok(!exists $a[6], "$msg{outl}, $msg{aenx}");

@a = ('a', 'b', 'c');
{
    local(@a[4,6]) = ('x', 'z');
    $a[5] = 'y';
    ok(!defined $a[3], "$msg{durl}, $msg{aend}");
    is($a[4], 'x', "$msg{durl}, $msg{geae}");
    is($a[5], 'y', "$msg{durl}, $msg{geae}");
    is($a[6], 'z', "$msg{durl}, $msg{geae}");
}
is(scalar(@a), 6, "$msg{outl}, $msg{genae}");
ok(!defined $a[3], "$msg{outl}, $msg{aend}");
ok(!defined $a[4], "$msg{outl}, $msg{aend}");
is($a[5], 'y', "$msg{outl}, $msg{geae}");
ok(!exists $a[6], "$msg{outl}, $msg{aenx}");

@a = ('a', 'b', 'c');
$a[4] = 'd';
{
    delete local $a[1];
    is(scalar(@a), 5, "$msg{durl}, $msg{genae}");
    is($a[0], 'a', "$msg{durl}, $msg{geae}");
    ok(!exists($a[1]), "$msg{durl}, $msg{aenx}");
    is($a[2], 'c', "$msg{durl}, $msg{geae}");
    ok(!exists($a[3]), "$msg{durl}, $msg{aenx}");
    is($a[4], 'd', "$msg{durl}, $msg{geae}");

    ok(!exists($a[888]), "$msg{durl}, $msg{aenx}");
    delete local $a[888];
    is(scalar(@a), 5, "$msg{durl}, $msg{genae}");
    ok(!exists($a[888]), "$msg{durl}, $msg{aenx}");

    ok(!exists($a[999]), "$msg{durl}, $msg{aenx}");
    my ($d, $zzz) = delete local @a[4, 999];
    is(scalar(@a), 3, "$msg{durl}, $msg{genae}");
    ok(!exists($a[4]), "$msg{durl}, $msg{aenx}");
    ok(!exists($a[999]), "$msg{durl}, $msg{aenx}");
    is($d, 'd', "$msg{durl}, $msg{ges}");
    is($zzz, undef, "$msg{durl}, $msg{vnde}");

    my $c = delete local $a[2];
    is(scalar(@a), 1, "$msg{durl}, $msg{genae}");
    ok(!exists($a[2]), "$msg{durl}, $msg{aenx}");
    is($c, 'c', "$msg{durl}, $msg{ges}");

    $a[888] = 'yyy';
    $a[999] = 'zzz';
}
is(scalar(@a), 5, "$msg{outl}, $msg{genae}");
is($a[0], 'a', "$msg{outl}, $msg{geae}");
is($a[1], 'b', "$msg{outl}, $msg{geae}");
is($a[2], 'c', "$msg{outl}, $msg{geae}");
ok(!defined($a[3]), "$msg{outl}, $msg{aend}");
is($a[4], 'd', "$msg{outl}, $msg{geae}");
ok(!exists($a[5]), "$msg{outl}, $msg{aenx}");
ok(!exists($a[888]), "$msg{outl}, $msg{aenx}");
ok(!exists($a[999]), "$msg{outl}, $msg{aenx}");

note("see if localization works on tied hashes");

{
    package TH;
    sub TIEHASH { bless {}, $_[0] }
    sub STORE { print "# STORE [@_]\n"; $_[0]->{$_[1]} = $_[2] }
    sub FETCH { my $v = $_[0]->{$_[1]}; print "# FETCH [@_=$v]\n"; $v }
    sub EXISTS { print "# EXISTS [@_]\n"; exists $_[0]->{$_[1]}; }
    sub DELETE { print "# DELETE [@_]\n"; delete $_[0]->{$_[1]}; }
    sub CLEAR { print "# CLEAR [@_]\n"; %{$_[0]} = (); }
    sub FIRSTKEY { print "# FIRSTKEY [@_]\n"; keys %{$_[0]}; each %{$_[0]} }
    sub NEXTKEY { print "# NEXTKEY [@_]\n"; each %{$_[0]} }
}

tie %h, 'TH';
%h = ('a' => 1, 'b' => 2, 'c' => 3);

{
    local($h{'a'}) = 'foo';
    local($h{'b'}) = $h{'b'};
    local($h{'y'});
    local($h{'z'}) = 33;
    is($h{'a'}, 'foo', "$msg{durl}, $msg{gehe}");
    is($h{'b'}, 2, "$msg{durl}, $msg{gehe}");
    local($h{'c'});
    delete $h{'c'};
}
is($h{'a'}, 1, "$msg{outl}, $msg{gehe}");
is($h{'b'}, 2, "$msg{outl}, $msg{gehe}");
is($h{'c'}, 3, "$msg{outl}, $msg{gehe}");

note("local() should preserve the existenceness of tied hash elements");

ok(! exists $h{'y'}, "$msg{outl}, $msg{henx}");
ok(! exists $h{'z'}, "$msg{outl}, $msg{henx}");
{
    my $d = join("\n", map { "$_=>$h{$_}" } sort keys %h);
    local %h = %h;
    is(join("\n", map { "$_=>$h{$_}" } sort keys %h), $d,
        "got expected result of sort, map, join");
}

note("RT #7939 (GH #4612): localising a hash should make it temporarily untied");

{
    %h = qw(a 1 b 2 c 3);
    local %h = qw(x 6 y 7 z 8);
    is(join('', sort keys   %h), "xyz", 'local %h has new keys');
    is(join('', sort values %h), "678", 'local %h has new values');
    {
        my $c = 0;
        no warnings 'redefine';
        local *TH::STORE = sub { $c++ };
        $h{x} = 9;
        is($c, 0, 'STORE not called after hash localised');
    }
    is($h{x}, 9, '$h{x} should now be 9');
}
is(join('', sort keys   %h), "abc", 'restored %h has original keys');
is(join('', sort values %h), "123", 'restored %h has original values');

%h = (a => 1, b => 2, c => 3, d => 4);
{
    delete local $h{b};
    is(scalar(keys(%h)), 3, "$msg{durl}, $msg{genhe}");
    is($h{a}, 1, "$msg{durl}, $msg{gehe}");
    ok(!exists($h{b}), "$msg{durl}, $msg{henx}");
    is($h{c}, 3, "$msg{durl}, $msg{gehe}");
    is($h{d}, 4, "$msg{durl}, $msg{gehe}");

    ok(!exists($h{yyy}), "$msg{durl}, $msg{henx}");
    delete local $h{yyy};
    is(scalar(keys(%h)), 3, "$msg{durl}, $msg{genhe}");
    ok(!exists($h{yyy}), "$msg{durl}, $msg{henx}");

    ok(!exists($h{zzz}), "$msg{durl}, $msg{henx}");
    my ($d, $zzz) = delete local @h{qw/d zzz/};
    is(scalar(keys(%h)), 2, "$msg{durl}, $msg{henx}");
    ok(!exists($h{d}), "$msg{durl}, $msg{henx}");
    ok(!exists($h{zzz}), "$msg{durl}, $msg{henx}");
    is($d, 4, "$msg{durl}, $msg{ges}");
    is($zzz, undef, "$msg{durl}, $msg{vnde}");

    my $c = delete local $h{c};
    is(scalar(keys(%h)), 1, "$msg{durl}, $msg{genhe}");
    ok(!exists($h{c}), "$msg{durl}, $msg{henx}");
    is($c, 3, "$msg{durl}, $msg{ges}");

    $h{yyy} = 888;
    $h{zzz} = 999;
}
is(scalar(keys(%h)), 4, "$msg{outl}, $msg{henx}");
is($h{a}, 1, "$msg{outl}, $msg{gehe}");
is($h{b}, 2, "$msg{outl}, $msg{gehe}");
is($h{c}, 3, "$msg{outl}, $msg{gehe}");
is($h{d}, 4, "$msg{outl}, $msg{gehe}");
ok(!exists($h{yyy}), "$msg{outl}, $msg{henx}");
ok(!exists($h{zzz}), "$msg{outl}, $msg{henx}");

@a = ('a', 'b', 'c');
{
    local($a[1]) = "X";
    shift @a;
}
is($a[0].$a[1], "Xb", "shift off global array $msg{outl} leaves expected elements");

note("now try the same for %SIG");

sub refoo {
    local($alpha, $beta) = @_;
    local($c, $d);
    $c = "c 3";
    $d = "d 4";
    { local($alpha,$c) = ("a 9", "c 10"); ($x, $y) = ($alpha, $c); }
    $c, $d;
}
$SIG{TERM} = 'foo';
$SIG{INT} = \&refoo;
$SIG{__WARN__} = $SIG{INT};
{
    local($SIG{TERM}) = $SIG{TERM};
    local($SIG{INT}) = $SIG{INT};
    local($SIG{__WARN__}) = $SIG{__WARN__};
    is($SIG{TERM}, 'main::foo', $msg{durl} . ' SIG{TERM}');
    is($SIG{INT}, \&refoo, $msg{durl} . ' SIG{INT}');
    is($SIG{__WARN__}, \&refoo, $msg{durl} . ' SIG{__WARN__}');
    local($SIG{INT});
    delete $SIG{__WARN__};
}
is($SIG{TERM}, 'main::foo', $msg{outl} . ' SIG{TERM}');
is($SIG{INT}, \&refoo, $msg{outl} . ' SIG{INT}');
is($SIG{__WARN__}, \&refoo, $msg{outl} . ' SIG{__WARN__}');

{
    my @keys = sort keys %SIG;
    my $d = join("\n", map { "$_=>$SIG{$_}" } sort keys %SIG);
    local %SIG = %SIG;
    is(join("\n", map { "$_=>$SIG{$_}" } sort keys %SIG), $d,
        "got expected result of sort, map, join");
}

note("and for %ENV");

$ENV{_X_} = 'a';
$ENV{_Y_} = 'b';
$ENV{_Z_} = 'c';
{
    local($ENV{_A_});
    local($ENV{_B_}) = 'foo';
    local($ENV{_X_}) = 'foo';
    local($ENV{_Y_}) = $ENV{_Y_};
    is($ENV{_X_}, 'foo', $msg{durl} . ' $ENV{_X_}');
    is($ENV{_Y_}, 'b',   $msg{durl} . ' $ENV{_Y_}');
    local($ENV{_Z_});
    delete $ENV{_Z_};
}
is($ENV{_X_}, 'a', $msg{outl} . ' $ENV{_X_}');
is($ENV{_Y_}, 'b', $msg{outl} . ' $ENV{_Y_}');
is($ENV{_Z_}, 'c', $msg{outl} . ' $ENV{_Z_}');

note("local() should preserve the existenceness of %ENV elements");
ok(! exists $ENV{_A_}, "$msg{outl}, $msg{henx}");
ok(! exists $ENV{_B_}, "$msg{outl}, $msg{henx}");

SKIP: {
    skip("Can't make list assignment to \%ENV on this system")
	    unless $list_assignment_supported;
    my $d = join("\n", map { "$_=>$ENV{$_}" } sort keys %ENV);
    local %ENV = %ENV;
    is(join("\n", map { "$_=>$ENV{$_}" } sort keys %ENV), $d,
        "got expected result of sort, map, join");
}

note("does implicit localization in foreach skip magic?");

$_ = "o 0,o 1,";
my $iter = 0;
while (/(o.+?),/gc) {
    is($1, "o $iter", "o $iter");
    foreach (1..1) { $iter++ }
    if ($iter > 2) { fail("endless loop"); last; }
}

note("package UnderScore");

{
    package UnderScore;
    sub TIESCALAR { bless \my $self, shift }
    sub FETCH { die "read  \$_ forbidden" }
    sub STORE { die "write \$_ forbidden" }
    tie $_, __PACKAGE__;
    my @tests = (
        "Nesting"     => sub { my $x = '#'; for (1..3) { $x .= $_ }
                               print "$x\n" },                  1,
        "Reading"     => sub { print },                         0,
        "Matching"    => sub { $x = /badness/ },                0,
        "Concat"      => sub { $_ .= "a" },                     0,
        "Chop"        => sub { chop },                          0,
        "Filetest"    => sub { -x },                            0,
        "Assignment"  => sub { $_ = "Bad" },                    0,
        "for local"   => sub { for("#ok?\n"){ print } },        1,
    );
    while ( my ($name, $code, $ok) = splice(@tests, 0, 3) ) {
        eval { &$code };
        main::ok(($ok xor $@), "Underscore '$name'");
    }
    untie $_;
}

{
    note("BUG 20001205.022 (RT #4852) (GH #2953)");
    my %x;
    $x{a} = 1;
    { local $x{b} = 1; }
    ok(! exists $x{b}, "$msg{outl}, $msg{henx}");
    { local @x{ ( qw| c d e | ) }; }
    ok(! exists $x{c}, "$msg{outl}, $msg{henx}");
}

note("local() and readonly magic variables");

eval { local $1 = 1 };
like($@, qr/Modification of a read-only value attempted/,
    "Got expected exception");

note("local($_) always strips all magic");
eval { for ($1) { local $_ = 1 } };
is($@, "", "No exception");

{
    my $STORE = my $FETCH = 0;
    package TieHash;
    sub TIEHASH { bless $_[1], $_[0] }
    sub FETCH   { ++$FETCH; 42 }
    sub STORE   { ++$STORE }

    package main;
    tie my %hash, "TieHash", {};

    eval { for ($hash{key}) {local $_ = 2} };
    is($STORE, 0, "Got expected value for STORE");
    is($FETCH, 0, "Got expected value for FETCH");;
}

note('The s/// adds \'g\' magic to $_, but it should remain non-readonly');

eval { for("a") { for $x (1,2) { local $_="b"; s/(.*)/+$1/ } } };
is($@, "", "Got no exception");

note('sub localisation');

{
	package Other;

	sub f1 { "f1" }
	sub f2 { "f2" }
	sub f3 { "f3" }
	sub f4 { "f4" }

	no warnings "redefine";
	{
		local *f1 = sub  { "g1" };
		::ok(f1() eq "g1", "localised sub via glob");
	}
	::ok(f1() eq "f1", "localised sub restored");
	{
		local $Other::{"f1"} = sub { "h1" };
		::ok(f1() eq "h1", "localised sub via stash");
	}
	::ok(f1() eq "f1", "localised sub restored");
	# Do that test again, but with a different glob, to make sure that
	# localisation via multideref can handle a subref in a stash.
	# (The local *f1 above will have ensured that we have a full glob,
	# not a sub ref.)
	{
		local $Other::{"f3"} = sub { "h1" };
		::ok(f3() eq "h1", "localised sub via stash");
	}
	::ok(f3() eq "f3", "localised sub restored");
	# Also, we need to test pp_helem, which we can do by using a more
	# complex subscript.
	{
		local $Other::{${\"f4"}} = sub { "h1" };
		::ok(f4() eq "h1", "localised sub via stash");
	}
	::ok(f4() eq "f4", "localised sub restored");
	{
		local @Other::{qw/ f1 f2 /} = (sub { "j1" }, sub { "j2" });
		::ok(f1() eq "j1", "localised sub via stash slice");
		::ok(f2() eq "j2", "localised sub via stash slice");
	}
	::ok(f1() eq "f1", "localised sub restored");
	::ok(f2() eq "f2", "localised sub restored");
}

note('Localising unicode keys (bug #38815) (GH #8386)');
{
    my %h;
    $h{"\243"} = "pound";
    $h{"\302\240"} = "octects";
    is(scalar keys %h, 2, "$msg{outl}, $msg{genhe}");
    {
        my $unicode = chr 256;
        my $ambigous = "\240" . $unicode;
        chop $ambigous;
        local $h{$unicode} = 256;
        local $h{$ambigous} = 160;

        is(scalar keys %h, 4, "$msg{durl}, $msg{genhe}");
        is($h{"\243"}, "pound", "$msg{durl}, $msg{ges}");
        is($h{$unicode}, 256, "$msg{durl}, $msg{ges}");
        is($h{$ambigous}, 160, "$msg{durl}, $msg{ges}");
        is($h{"\302\240"}, "octects", "$msg{durl}, $msg{ges}");
    }
    is(scalar keys %h, 2, "$msg{outl}, $msg{genhe}");
    is($h{"\243"}, "pound", "$msg{outl}, $msg{ges}");
    is($h{"\302\240"}, "octects", "$msg{outl}, $msg{ges}");
}

note("And with slices");
{
    my %h;
    $h{"\243"} = "pound";
    $h{"\302\240"} = "octects";
    is(scalar keys %h, 2, "$msg{outl}, $msg{genhe}");
    {
        my $unicode = chr 256;
        my $ambigous = "\240" . $unicode;
        chop $ambigous;
        local @h{$unicode, $ambigous} = (256, 160);

        is(scalar keys %h, 4, "$msg{durl}, $msg{genhe}");
        is($h{"\243"}, "pound", "$msg{durl}, $msg{ges}");
        is($h{$unicode}, 256, "$msg{durl}, $msg{ges}");
        is($h{$ambigous}, 160, "$msg{durl}, $msg{ges}");
        is($h{"\302\240"}, "octects", "$msg{durl}, $msg{ges}");
    }
    is(scalar keys %h, 2, "$msg{outl}, $msg{genhe}");
    is($h{"\243"}, "pound", "$msg{outl}, $msg{ges}");
    is($h{"\302\240"}, "octects", "$msg{outl}, $msg{ges}");
}

note("[perl #39012] [GH #8420] localizing @_ element then shifting frees element too soon");

{
    my $x;
    my $y = bless [], 'X39012';
    sub X39012::DESTROY { $x++ }
    sub { local $_[0]; shift }->($y);
    ok(!$x,  '[GH 8420]');
    
}

note("when localising a hash element, the key should be copied, not referenced");

{
    my %h=('k1' => 111);
    my $k='k1';
    {
        local $h{$k}=222;
        is($h{'k1'},222, "$msg{durl}, $msg{gehe}");
        $k='k2';
    }
    ok(! exists($h{'k2'}), "$msg{outl}, $msg{henx}");
    is($h{'k1'},111, "$msg{outl}, $msg{gehe}");
}
{
    my %h=('k1' => 111);
    our $k = 'k1';  # try dynamic too
    {
        local $h{$k}=222;
        is($h{'k1'},222, "$msg{durl}, $msg{gehe}");
        $k='k2';
    }
    ok(! exists($h{'k2'}), "$msg{outl}, $msg{henx}");
    is($h{'k1'},111, "$msg{outl}, $msg{gehe}");
}

like(
    runperl(
        stderr => 1,
        prog => 'use constant foo => q(a);' .
                'index(q(a), foo);' .
                'local *g=${::}{foo};print q(ok);'
    ),
    qr/^ok$/,
    "[perl #52740] [GH #9287]"
);

note("Related to RT #112966 / GH #12112");
note("Magic should not cause elements not to be deleted after scope unwinding\n" .
    "when they did not exist before local()");
our @squinch;
() = \$#squinch; # $#foo in lvalue context makes array magical
{
    local $squinch[0];
    local @squinch[1..2];
    package Flibbert;
    m??; # makes stash magical
    local $Flibbert::{foo};
    local @Flibbert::{<bar baz>};
}
ok !exists $Flibbert::{foo},
  'local helem on magic hash does not leave elems on scope exit';
ok !exists $Flibbert::{bar},
  'local hslice on magic hash does not leave elems on scope exit';
ok !exists $squinch[0],
  'local aelem on magic hash does not leave elems on scope exit';
ok !exists $squinch[1],
  'local aslice on magic hash does not leave elems on scope exit';

note("Keep these tests last, as they can SEGV");
{
    local *@;
    pass("Localised *@");
    eval {1};
    pass("Can eval with *@ localised");

    no strict 'refs';
    local @{"nugguton"};
    local %{"netgonch"};
    delete $::{$_} for 'nugguton','netgonch';
}
pass ('localised arrays and hashes do not crash if glob is deleted');

note('[perl #112966] [GH #12112] Rmagic can cause delete local to crash');

package Grompits {
    our @ISA;
    local $SIG{__WARN__};
    delete local $ISA[0];
    delete local @ISA[1..10];
    m??; # makes stash magical
    delete local $Grompits::{foo};
    delete local @Grompits::{<foo bar>};
}
pass 'rmagic does not cause delete local to crash on nonexistent elems';

TODO: {
    my @a = (1..5);
    {
        no warnings 'syntax'; # Compile-time: Useless localization of array length
        local $#a = 2;
        is($#a, 2, 'RT #7411 GH #4261: local($#a) should change count');
        is("@a", '1 2 3', 'RT #7411 GH #4261: local($#a) should shorten array');
    }

    local $::TODO = 'RT #7411 GH #4261: local($#a)';

    is($#a, 4, 'RT #7411 GH #4261: after local($#a), count should be restored');
    is("@a", '1 2 3 4 5', 'RT #7411 GH #4261: after local($#a), array should be restored');
}

$alpha = 10;
TODO: {
    local $::TODO = 'RT #GH #4370: if (local $alpha)';
    no warnings 'syntax'; # Compile-time: Found = in conditional, should be ==
    if (local $alpha = 1){
    }
    is($alpha, 10, 'RT #GH #4370: local in if condition should be restored');
}
