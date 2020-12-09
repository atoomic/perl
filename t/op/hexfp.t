#!./perl

BEGIN {
    chdir 't' if -d 't';
    require './test.pl';
    set_up_inc('../lib');
}

use strict;

use Config;

plan(tests => 125);

# Test hexfloat literals.

is(0x0p0, 0, '0x0p0');
is(0x0.p0, 0, '0x0.p0');
is(0x.0p0, 0, '0x.0p0');
is(0x0.0p0, 0, '0x0.0p0');
is(0x0.00p0, 0, '0x0.00p0');

is(0x1p0, 1, '0x1p0');
is(0x1.p0, 1, '0x1.p0');
is(0x1.0p0, 1, '0x1.0p0');
is(0x1.00p0, 1, '0x1.00p0');

is(0x2p0, 2, '0x2p0');
is(0x2.p0, 2, '0x2.p0');
is(0x2.0p0, 2, '0x2.0p0');
is(0x2.00p0, 2, '0x2.00p0');

is(0x1p1, 2, '0x1p1');
is(0x1.p1, 2, '0x1.p1');
is(0x1.0p1, 2, '0x1.0p1');
is(0x1.00p1, 2, '0x1.00p1');

is(0x.1p0, 0.0625, '0x.1p0');
is(0x0.1p0, 0.0625, '0x0.1p0');
is(0x0.10p0, 0.0625, '0x0.10p0');
is(0x0.100p0, 0.0625, '0x0.100p0');

is(0x.1p0, 0.0625, '0x.1p0');
is(0x1.1p0, 1.0625, '0x1.1p0');
is(0x1.11p0, 1.06640625, '0x1.11p0');
is(0x1.111p0, 1.066650390625, '0x1.111p0');

# Positive exponents.
is(0x1p2, 4, '0x1p2');
is(0x1p+2, 4, '0x1p+2');
is(0x0p+0, 0, '0x0p+0');

# Negative exponents.
is(0x1p-1, 0.5, '0x1p-1');
is(0x1.p-1, 0.5, '0x1.p-1');
is(0x1.0p-1, 0.5, '0x1.0p-1');
is(0x0p-0, 0, '0x0p-0');

is(0x1p+2, 4, '0x1p+2');
is(0x1p-2, 0.25, '0x1p-2');

is(0x3p+2, 12, '0x3p+2');
is(0x3p-2, 0.75, '0x3p-2');

# Shifting left.
is(0x1p2, 1 << 2, '0x1p2');
is(0x1p3, 1 << 3, '0x1p3');
is(0x3p4, 3 << 4, '0x3p4');
is(0x3p5, 3 << 5, '0x3p5');
is(0x12p23, 0x12 << 23, '0x12p23');

# Shifting right.
is(0x1p-2, 1 / (1 << 2), '0x1p-2');
is(0x1p-3, 1 / (1 << 3), '0x1p-3');
is(0x3p-4, 3 / (1 << 4), '0x3p-4');
is(0x3p-5, 3 / (1 << 5), '0x3p-5');
is(0x12p-23, 0x12 / (1 << 23), '0x12p-23');

# Negative sign.
is(-0x1p+2, -4, '-0x1p+2');
is(-0x1p-2, -0.25, '-0x1p-2');
is(-0x0p+0, 0, '-0x0p+0');
is(-0x0p-0, 0, '-0x0p-0');

is(0x0.10p0, 0.0625, '0x0.10p0');
is(0x0.1p0, 0.0625, '0x0.1p0');
is(0x.1p0, 0.0625, '0x.1p0');

is(0x12p+3, 144, '0x12p+3');
is(0x12p-3, 2.25, '0x12p-3');

# Hexdigits (lowercase).
is(0x9p+0, 9, '0x9p+0');
is(0xap+0, 10, '0xap+0');
is(0xfp+0, 15, '0xfp+0');
is(0x10p+0, 16, '0x10p+0');
is(0x11p+0, 17, '0x11p+0');
is(0xabp+0, 171, '0xabp+0');
is(0xab.cdp+0, 171.80078125, '0xab.cdp+0');

# Uppercase hexdigits and exponent prefix.
is(0xAp+0, 10, '0xAp+0');
is(0xFp+0, 15, '0xFp+0');
is(0xABP+0, 171, '0xABP+0');
is(0xAB.CDP+0, 171.80078125, '0xAB.CDP+0');

# Underbars.
is(0xa_b.c_dp+1_2, 703696, '0xa_b.c_dp+1_2');

# Note that the hexfloat representation is not unique since the
# exponent can be shifted, and the hexdigits with it: this is no
# different from 3e4 cf 30e3 cf 30000.  The shifting of the hexdigits
# makes it look stranger, though: 0xap1 == 0x5p2.

# [perl #127183], try some non-canonical forms.
SKIP: {
    skip("nv_preserves_uv_bits is $Config{nv_preserves_uv_bits} not 53", 3)
        unless ($Config{nv_preserves_uv_bits} == 53);
    is(0x0.b17217f7d1cf78p0, 0x1.62e42fefa39efp-1, '0x0.b17217f7d1cf78p0');
    is(0x0.58b90bfbe8e7bcp1, 0x1.62e42fefa39efp-1, '0x0.58b90bfbe8e7bcp1');
    is(0x0.2c5c85fdf473dep2, 0x1.62e42fefa39efp-1, '0x0.2c5c85fdf473dep2');
}

# Needs to use within() instead of is() because of long doubles.
within(0x1.99999999999ap-4, 0.1, 1e-9, '0x1.99999999999ap-4');
within(0x3.333333333333p-5, 0.1, 1e-9, '0x3.333333333333p-5');
within(0xc.cccccccccccdp-7, 0.1, 1e-9, '0xc.cccccccccccdp-7');

my $warn;

local $SIG{__WARN__} = sub { $warn = shift };

sub get_warn() {
    my $save = $warn;
    undef $warn;
    return $save;
}

{ # Test certain things that are not hexfloats and should stay that way.
    eval '0xp3';
    like(get_warn(), qr/Missing operator before p3/, '0xp3');

    eval '5p3';
    like(get_warn(), qr/Missing operator before p3/, '5p3');

    my @a;
    eval '@a = 0x3..5';
    is("@a", "3 4 5", '@a = 0x3..5');

    undef $a;
    eval '$a = eval "0x.3"';
    is($a, undef, '$a = eval "0x.3"'); # throws an error

    undef $a;
    eval '$a = eval "0xc.3"';
    is($a, '123', '$a = eval "0xc.3"');

    undef $a;
    eval '$a = eval "0x.p3"';
    is($a, undef, '$a = eval "0x.p3"');
}

# Test warnings.
SKIP:
{
    skip "nv_preserves_uv_bits is $Config{nv_preserves_uv_bits} not 53", 26
        unless $Config{nv_preserves_uv_bits} == 53;

    eval '0x1_0000_0000_0000_0p0';
    is(get_warn(), undef, '0x1_0000_0000_0000_0p0');

    eval '0x2_0000_0000_0000_0p0';
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '0x2_0000_0000_0000_0p0');

    eval '0x1.0000_0000_0000_0p0';
    is(get_warn(), undef, '0x1.0000_0000_0000_0p0');

    eval '0x2.0000_0000_0000_0p0';
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '0x2.0000_0000_0000_0p0');

    eval '0x.1p-1021';
    is(get_warn(), undef, '0x.1p-1021');

    eval '0x.1p-1023';
    like(get_warn(), qr/^Hexadecimal float: exponent underflow/, '0x.1p-1023');

    eval '0x1.fffffffffffffp+1023';
    is(get_warn(), undef, '0x1.fffffffffffffp+1023');

    eval '0x1.fffffffffffffp+1024';
    like(get_warn(), qr/^Hexadecimal float: exponent overflow/, '0x1.fffffffffffffp+1024');

    undef $a;
    eval '$a = 0x111.0000000000000p+0'; # 12 zeros.
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '$a = 0x111.0000000000000p+0');
    is($a, 273, '$a = 0x111.0000000000000p+0');

    # The 13 zeros would be enough to push the hi-order digits
    # off the high-end.

    undef $a;
    eval '$a = 0x111.0000000000000p+0'; # 13 zeros.
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '$a = 0x111.0000000000000p+0');
    is($a, 273, '$a = 0x111.0000000000000p+0');

    undef $a;
    eval '$a = 0x111.00000000000000p+0'; # 14 zeros.
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '$a = 0x111.00000000000000p+0');
    is($a, 273, '$a = 0x111.00000000000000p+0');

    undef $a;
    eval '$a = 0xfffffffffffffp0'; # 52 bits.
    is(get_warn(), undef, '$a = 0xfffffffffffffp0');
    is($a, 4.5035996273705e+15, '$a = 0xfffffffffffffp0');

    undef $a;
    eval '$a = 0xfffffffffffff.8p0'; # 53 bits.
    is(get_warn(), undef, '$a = 0xfffffffffffff.8p0');
    is($a, 4.5035996273705e+15, '$a = 0xfffffffffffff.8p0');

    undef $a;
    eval '$a = 0xfffffffffffff.cp0'; # 54 bits.
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '$a = 0xfffffffffffff.cp0');
    is($a, 4.5035996273705e+15, '$a = 0xfffffffffffff.cp0');

    undef $a;
    eval '$a = 0xf.ffffffffffffp0'; # 52 bits.
    is(get_warn(), undef, '$a = 0xf.ffffffffffffp0');
    is($a, 16, '$a = 0xf.ffffffffffffp0');

    undef $a;
    eval '$a = 0xf.ffffffffffff8p0'; # 53 bits.
    is(get_warn(), undef, '$a = 0xf.ffffffffffff8p0');
    is($a, 16, '$a = 0xf.ffffffffffff8p0');

    undef $a;
    eval '$a = 0xf.ffffffffffffcp0'; # 54 bits.
    like(get_warn(), qr/^Hexadecimal float: mantissa overflow/, '$a = 0xf.ffffffffffffcp0');
    is($a, 16, '$a = 0xf.ffffffffffffcp0');
}

# [perl #128919] limited exponent range in hex fp literal with long double
SKIP: {
    skip("non-80-bit-long-double", 4)
        unless ($Config{uselongdouble} &&
		($Config{nvsize} == 16 || $Config{nvsize} == 12) &&
		($Config{long_double_style_ieee_extended}));
    is(0x1p-1074,  4.94065645841246544e-324, '0x1p-1074');
    is(0x1p-1075,  2.47032822920623272e-324, '[perl #128919]');
    is(0x1p-1076,  1.23516411460311636e-324, '0x1p-1076');
    is(0x1p-16445, 3.6451995318824746e-4951, '0x1p-16445');
}

# [perl #131894] parsing long binaryish floating point literals used to
# perform illegal bit shifts.  Need 64-bit ints to test.
SKIP: {
    skip("non-64-bit NVs or no 64-bit ints to test with", 3)
      unless $Config{nvsize} == 8 && $Config{d_double_style_ieee} && $Config{use64bitint};
    is sprintf("%a", eval("0x030000000000000.1p0")),
        "0x1.8p+53",
        '0x1.8p+53';
    is sprintf("%a", eval("01400000000000000000.1p0")),
        "0x1.8p+54",
        '0x1.8p+54';
    is sprintf("%a", eval("0b110000000000000000000000000000000000000000000000000000000.1p0")),
        "0x1.8p+56",
        '0x1.8p+56';
}

# the implementation also allow for octal and binary fp
is(01p0, 1, '01p0');
is(01.0p0, 1, '01.0p0');
is(01.00p0, 1, '01.00p0');
is(010.1p0, 8.125, '010.1p0');
is(00.400p1, 1, '00.400p1');
is(00p0, 0, '00p0');
is(01.1p0, 1.125, '01.1p0');

is(0b0p0, 0, '0b0p0');
is(0b1p0, 1, '0b1p0');
is(0b10p0, 2, '0b10p0');
is(0b1.1p0, 1.5, '0b1.1p0');

# previously these would pass "0x..." to the overload instead of the appropriate
# "0b" or "0" prefix.
fresh_perl_is(<<'CODE', "1", {}, "overload binary fp");
use overload;
BEGIN { overload::constant float => sub { return eval $_[0]; }; }
print 0b0.1p1;
CODE

fresh_perl_is(<<'CODE', "1", {}, "overload octal fp");
use overload;
BEGIN { overload::constant float => sub { return eval $_[0]; }; }
print 00.1p3;
CODE

# sprintf %a/%A testing is done in sprintf2.t,
# trickier than necessary because of long doubles,
# and because looseness of the spec.
