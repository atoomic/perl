#!./perl
# Tests for caller()

#use warnings;
BEGIN {
    chdir 't' if -d 't';
    require './test.pl';
    set_up_inc('../lib');
    plan( tests =>  1 ); # some tests are run in a BEGIN block
}

# The bitmask should be assignable to ${^WARNING_BITS} without resulting in
# different warnings settings.
{
 my $bits = sub { (caller 0)[9] }->();
 my $w;
 local $SIG{__WARN__} = sub { $w++ };
 eval '
   use warnings;
   BEGIN { ${^WARNING_BITS} = $bits }
   local $^W = 1;
   () = 1 + undef;
   $^W = 0;
   () = 1 + undef;
 ';
 is $w, 1, 'value from (caller 0)[9] (bitmask) works in ${^WARNING_BITS}';
}
