#!./perl

BEGIN {
    chdir 't' if -d 't';
    require "./test.pl";
    set_up_inc('../lib');
}

plan(26);

my $tmpfile = tempfile();
open (TMP,'>', $tmpfile) || die "Can't create Cmd_while.tmp.";
print TMP "tvi925\n";
print TMP "tvi920\n";
print TMP "vt100\n";
print TMP "Amiga\n";
print TMP "paper\n";
close TMP or die "Could not close: $!";

# test "last" command

open(FH, $tmpfile) || die "Can't open Cmd_while.tmp.";
while (<FH>) {
    last if /vt100/;
}
ok(!eof && /vt100/);

# test "next" command

my $bad = '';
open(FH, $tmpfile) || die "Can't open Cmd_while.tmp.";
while (<FH>) {
    next if /vt100/;
    $bad = 1 if /vt100/;
}
{ no warnings 'uninitialized'; ok(eof && !/vt100/ && !$bad); }

# test "redo" command

$bad = '';
open(FH,$tmpfile) || die "Can't open Cmd_while.tmp.";
while (<FH>) {
    if (s/vt100/VT100/g) {
        s/VT100/Vt100/g;
        redo;
    }
    $bad = 1 if /vt100/;
    $bad = 1 if /VT100/;
}
ok(eof && !$bad);

# now do the same with a label and a continue block

# test "last" command

my $badcont = '';
open(FH,$tmpfile) || die "Can't open Cmd_while.tmp.";
line: while (<FH>) {
    if (/vt100/) {last line;}
} continue {
    $badcont = 1 if /vt100/;
}
ok(!eof && /vt100/);
ok(!$badcont);

# test "next" command

$bad = '';
$badcont = 1;
open(FH,$tmpfile) || die "Can't open Cmd_while.tmp.";
entry: while (<FH>) {
    next entry if /vt100/;
    $bad = 1 if /vt100/;
} continue {
    $badcont = '' if /vt100/;
}
{ no warnings 'uninitialized'; ok(eof && !/vt100/ && !$bad); }
ok(!$badcont);

# test "redo" command

$bad = '';
$badcont = '';
open(FH,$tmpfile) || die "Can't open Cmd_while.tmp.";
loop: while (<FH>) {
    if (s/vt100/VT100/g) {
        s/VT100/Vt100/g;
        redo loop;
    }
    $bad = 1 if /vt100/;
    $bad = 1 if /VT100/;
} continue {
    $badcont = 1 if /vt100/;
}
ok(eof && !$bad);
ok(!$badcont);

close(FH) || die "Can't close Cmd_while.tmp.";

my $i = 9;
{
    $i++;
}
is($i, 10);

# Check curpm is reset when jumping out of a scope
$i = 0;
'abc' =~ /b/;
WHILE:
while (1) {
  $i++;
  is($` . $& . $', "abc");
  {                             # Localize changes to $` and friends
    'end' =~ /end/;
    redo WHILE if $i == 1;
    next WHILE if $i == 2;
    # 3 do a normal loop
    last WHILE if $i == 4;
  }
}
is($` . $& . $', "abc");

# check that scope cleanup happens right when there's a continue block
{
    my $var = 16;
    my ($got_var, $got_i);
    while (my $i = ++$var) {
        next if $i == 17;
        last if $i > 17;
        my $i = 0;
    }
    continue {
        ($got_var, $got_i) = ($var, $i);
    }
    is($got_var, 17);
    is($got_i, 17);
}

{
    no strict 'vars';
    {
        my $got_l;
        local $l = 18;
        {
            local $l = 0
        }
        continue {
            $got_l = $l;
        }
        is($got_l, 18);
    }

    {
        my $got_l;
        local $l = 19;
        my $x = 0;
        while (!$x++) {
            local $l = 0
        }
        continue {
            $got_l = $l;
        }
        is($got_l, $l);
    }
}

{
    my $ok = 1;
    $i = 20;
    while (1) {
        my $x;
        $ok = 0 if defined $x;
        if ($i == 21) {
            next;
        }
        last;
    }
    continue {
        ++$i;
    }
    ok($ok);
}

sub save_context { $_[0] = wantarray; $_[1] }

{
    my $context = -1;
    my $p = sub {
        my $x = 1;
        while ($x--) {
            save_context($context, "foo");
        }
    };
    is(scalar($p->()), 0);
    is($context, undef, "last statement in while block has 'void' context");
}

{
    my $context = -1;
    my $p = sub {
        my $x = 1;
        {
            save_context($context, "foo");
        }
    };
    is(scalar($p->()), "foo");
    is($context, "", "last statement in block has 'scalar' context");
}

{
    # test scope is cleaned
    my $i = 0;
    my @a;
    while ($i++ < 2) {
        my $x;
        push @a, \$x;
    }
    ok($a[0] ne $a[1]);
}

fresh_perl_is <<'72406', "foobar\n", {},
{ package o; use overload bool => sub { no warnings 'once'; die unless $::ok++; return 1 } }
use constant OK => bless [], o::;
do{print("foobar\n");}until OK;
72406
    "[perl #72406] [gh #10117] segv with do{}until CONST where const is not folded";
