################################################################################
#
#            !!!!!   Do NOT edit this file directly!   !!!!!
#
#            Edit mktests.PL and/or parts/inc/pv_tools instead.
#
#  This file was automatically generated from the definition files in the
#  parts/inc/ subdirectory by mktests.PL. To learn more about how all this
#  works, please read the F<HACKERS> file that came with this distribution.
#
################################################################################

use FindBin ();

BEGIN {
  if ($ENV{'PERL_CORE'}) {
    chdir 't' if -d 't';
    unshift @INC, '../lib' if -d '../lib' && -d '../ext';
    require Config; Config->import;
    use vars '%Config';
    if (" $Config{'extensions'} " !~ m[ Devel/PPPort ]) {
      print "1..0 # Skip -- Perl configured without Devel::PPPort module\n";
      exit 0;
    }
  }

  use lib "$FindBin::Bin";
  use lib "$FindBin::Bin/../parts/inc";

  die qq[Cannot find "$FindBin::Bin/../parts/inc"] unless -d "$FindBin::Bin/../parts/inc";

  sub load {
    require 'testutil.pl';
    require 'inctools';
  }

  if (13) {
    load();
    plan(tests => 13);
  }
}

use Devel::PPPort;
use strict;
BEGIN { $^W = 1; }

package Devel::PPPort;
use vars '@ISA';
require DynaLoader;
@ISA = qw(DynaLoader);
Devel::PPPort->bootstrap;

package main;

my $uni = &Devel::PPPort::pv_escape_can_unicode();

# sanity check
ok($uni ? "$]" >= 5.006 : "$]" < 5.008);

my @r;

@r = &Devel::PPPort::pv_pretty();
is($r[0], $r[1]);
is($r[0], "foobarbaz");
is($r[2], $r[3]);
is($r[2], '<leftpv_p\retty\nright>');
is($r[4], $r[5]);
if(ord("A") == 65) {
    is($r[4], $uni ? 'N\375 Batter\355' : 'N\303\275 Batter\303');
}
else {
    skip("Skip for non-ASCII platform");
}
is($r[6], $r[7]);
if(ord("A") == 65) {
    is($r[6], $uni ? '\301g\346tis Byrju...' : '\303\201g\303\246t...');
}
else {
    skip("Skip for non-ASCII platform");
}

@r = &Devel::PPPort::pv_display();
is($r[0], $r[1]);
is($r[0], '"foob\0rbaz"\0');
is($r[2], $r[3]);
ok($r[2] eq '"pv_di"...\0' ||
   $r[2] eq '"pv_d"...\0');  # some perl implementations are broken... :(

