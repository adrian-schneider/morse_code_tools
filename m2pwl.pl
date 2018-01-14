#!/usr/bin/perl -w

use strict;
#eval("use diagnostics"); # not all perls provide diagnostics.

use Getopt::Std; $Getopt::Std::STANDARD_HELP_VERSION = 1;
# avoid "Name "Getopt::Std::STANDARD_HELP_VERSION" used only once: possible typo at pwl.pl line 7."
my $_x = $Getopt::Std::STANDARD_HELP_VERSION;

my %opts;
exit 1 if !getopts("1t:v:", \%opts);
my $argdittime  = $opts{t} ? $opts{t} : 0.3;
my $argvoltage  = $opts{v} ? $opts{v} : 1.0;
my $argfrmt1    = $opts{1};
my $argrisetime = $argdittime / 100.0;

my $argmorse = $ARGV[0];

my $time = 0.0;

sub VERSION_MESSAGE($) {
  my $fh = shift;
  print $fh "v1.0\n";
}

sub HELP_MESSAGE($) {
  my $fh = shift;
  print $fh <<END_USAGE;
Usage: m2pwl.pl [-OPTIONS] [--] '[morse-code]' 
       [stream] | m2pwl.pl [-OPTIONS] [--]

Convert morse-code into a SPICE pwl signal sequence.

  -t value  Define the time of a dit.
  -v value  Define the voltage of the output signal. Default is 1V.
  -1        Use one column output format.
  --help    Show this help text.
  --version Show program version.
  --        Is required if morse-code starts with an '-', to
            distinguish it from an option.
  morse-code
    .       output a dit.
    -       output a dah.
    space   output a word space.
    /       output a sentence space.   
END_USAGE
  exit;
}

#
# Convert a (SPICE) exponential suffix to an exponential value. 
# E.g. u is micro is 1e-6.
#
##sub sfx2exp($) {
##  # Suffixes are not case sensitive.
##  my $sfx = lc shift;
##  $sfx eq "" && return 1;
##  $sfx eq "g" && return 1e9;
##  $sfx eq "meg" && return 1e6;
##  $sfx eq "k" && return 1e3;
##  $sfx eq "m" && return 1e-3;
##  $sfx eq "u" && return 1e-6;
##  $sfx eq "n" && return 1e-9;
##  $sfx eq "p" && return 1e-12;
##  $sfx eq "f" && return 1e-15;
##  
##  die "invalid exponential suffix '$sfx', should not get there.";
##}

#
# Try to tokenize a number with exponential suffix and return its
# effective value.
# If the argument is a number with suffix, the value and suffix as 
# $$vRef and $$vxRef. Otherwise these values are unchanged. 
#
##sub numsfx2val($$) {
##  my $vRef = shift;
##  my $vxRef = shift;
##  if ($$vRef =~ /([+\-0-9\.e]+)(\D+)$/m) {
##    $$vRef = $1;
##    $$vxRef = $2;
##    return $$vRef * sfx2exp($$vxRef);
##  }
##  else {
##    return $$vRef;
##  }
##}

#
# Conveniently return the effective value of a suffixed number.
# The argument may be undefined (returns undefined too).
#
##sub sfxval($) {
##  my $v = shift;
##  my $vx; # ignored
##  return $v ? numsfx2val(\$v, \$vx) : $v;
##}

#
# Output time/voltage sequence for a mark signal.
# Consider duration and raise/fall times.
# Return back to zero.
# t: duration
#
sub mark($) {
  my $t = shift;
  if ($argfrmt1) {
    for (1..$t) { print "$argvoltage\n"; }
  } else {
    $time += $argrisetime;
    print "$time\t$argvoltage\n";
    $time += $t * $argdittime;
    print "$time\t$argvoltage\n";
    $time += $argrisetime;
    print "$time\t0\n";
  }
}

#
# Output time/voltage sequence for a space signal.
# t: duration
#
sub space ($) {
  my $t = shift;
  if ($argfrmt1) {
    for (1..$t) { print "0\n"; }
  } else {
    $time += $t * $argdittime;
    print "$time\t0\n";
  }
}


sub translate() {
  my $lastmark = 0;

  for (my $i = 0; $i < length($argmorse); $i++) {
    my $c = substr($argmorse, $i, 1);
    if ($c eq '.') {
      space(1) if ($lastmark);
      mark(1);
      $lastmark = 1;
    }
    elsif ($c eq '-') {
      space(1) if ($lastmark);
      mark(3);
      $lastmark = 1;
    }
    elsif ($c eq ' ') {
      space(3);
      $lastmark = 0;
    }
    elsif ($c eq '/') {
      space(7);
      $lastmark = 0;
    }
  }
}


#
# MAIN
#
if (defined $argmorse) {
  unless ($argfrmt1) { print "$time\t0\n"; }
  translate();
}

else {
  unless ($argfrmt1) { print "$time\t0\n"; }
  while (<>) {
    $argmorse = $_;
    translate();
  }
}

