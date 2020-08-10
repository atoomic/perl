#!./perl -w

# Test that there are no missing Maintainers in Maintainers.pl

BEGIN {
    # This test script uses a slightly atypical invocation of the 'standard'
    # core testing setup stanza.
    # The existing porting tools which manage the Maintainers file all
    # expect to be run from the root
    # XXX that should be fixed
    chdir '..' if -f 'test.pl';
    unshift @INC, qw[ lib Porting ];
}

use Config;
use Test::More;
plan skip_all( "Odd failures during cross-compilation" )
    if ( $Config{usecrosscompile} );
plan skip_all("Maintainers doesn't currently work for '-DPERL_EXTERNAL_GLOB'")
    if ( $Config{ccflags} =~ /-DPERL_EXTERNAL_GLOB/);
plan skip_all("home-grown glob doesn't handle fancy patterns")
    if ($^O eq 'VMS');

use warnings;
use Maintainers qw(show_results process_options finish_tap_output);

{
    local @ARGV = qw|--checkmani|;
    show_results(process_options());
}

{
    local @ARGV = qw|--checkmani lib/ ext/|;
    show_results(process_options());
}

finish_tap_output();

# EOF
