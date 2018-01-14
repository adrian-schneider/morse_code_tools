#!/usr/bin/perl -w

use strict;
use integer;
use Getopt::Std;

# Maximum number of marks (dots/dashes) in one morse character.
my $max_nrof_marks = 5;

# Size of (half) the ascii code string.
my $size_ascii_str = 2 ** $max_nrof_marks - 1;

# Character to encode unoccupied places in the ascii code string.
my $no_code_chr    = '°';

my $m2a_i = 0;
my $m2a_j = 0;
my $m2a_k = $max_nrof_marks;


#                       1         2         3
#             0123456789012345678901234567890
my $m2a_c  = "EIASURWHVFÜLÄPJ54°3É°°2°È+°°À°1"; # Codes starting with a dot.
   $m2a_c .= "TNMDKGOBXCYZQÖ°6=/°°°(°7°°Ñ8°90"; # Codes starting with a dash.


sub checkAsciiStr() {
  if (length($m2a_c) != ($size_ascii_str + $size_ascii_str)) {
    die "Ascii string has wrong size, probably contains non-ascii characters.";
  }
}


sub VERSION_MESSAGE($) {
  my $fh = shift;
  print $fh "v1.0\n";
}

sub HELP_MESSAGE($) {
  my $fh = shift;
  print $fh <<END_USAGE;
Usage: m2a.pl -m [--] '[morse-string]'
       m2a.pl -a [--] '[ascii-string]'
       [input-stream] | m2a.pl [options]

Convert morse-code into ascii and vice versa.

   -a       Convert from ascii to morse.
   -m       Convert from morse to ascii.
  --help    Show this help text.
  --version Show program version.
  --        Is required if morse-code starts with an '--', to
            distinguish it from an option.
  morse-string
    .       A dit.
    -       A dah.
    space   An inter-character space (length 3 x dit).
    /       An inter-word space (lenght 7 x dit).   
END_USAGE
  exit;
}


# Repeatedly call this function for all marks (dots/dashes) of
# one morse character.
# Then call it again with -1 and it will return the respective
# ascii character.
# This will also reinitialize the function for the next morese
# code sequence.
#
# Arguments
#   s:      -1,0,1
#     1 end of morse code sequence, get result.
#     0 input a dot.
#     1 input a dash.
#   rascii: String-ref. Reference to a variable to receive the ascii character.
#
# Return values
#   0 good, continue calling
#   1 error, too many marks, stop calling
#   2 error, no matching ascii character found
#   X the ascii representation of the decoded morese code
#
sub morse2ascii($$) {
  my $s      = shift;
  my $rascii = shift;

  # End decoding and return the result.
  if ($s == -1) {
    $m2a_k = $max_nrof_marks;
    my $ascii = substr($m2a_c, $m2a_i + $m2a_j, 1);
    # For reinitialization a dummy reference may have been given.
    if ($rascii != 0) {
      $$rascii = ($ascii ne $no_code_chr ? $ascii : '');
      return ($ascii ne $no_code_chr ? 0 : 2);
    }
    else {
      return 0;
    }
  }

  # Decode another mark.
  elsif (($s == 0) || ($s == 1)) {
    # No more marks can be processed, error.
    if ($m2a_k == 0) {
      return 1;
    }

    # Processing the first mark.
    elsif ($m2a_k == $max_nrof_marks) {
      $m2a_i = 0;
      $m2a_j = $s * $size_ascii_str;
    }

    # Processing further marks.
    else {
      $m2a_i = $m2a_i + $m2a_i + $s + 1;
    }

    $m2a_k--;
    return 0;
  }
}


# Convert the supplied character x to morse code.
#
# Arguments
#   x:      Any extended ascii character
#   rmorse: String-ref. The morse code representation of x
#
# Return values
#   0 good
#   2 invalid character x supplied
#
sub ascii2morse($$) {
  my $x      = shift;
  my $rmorse = shift;
  my $i      = index($m2a_c, $x);
  my $j      = 0;

  if ($i >= 0) {
    if ($i >= $size_ascii_str) {
      $i -= $size_ascii_str;
      $j  = 1;
    }

    while (1) {
      if ($i == 0) {
        $$rmorse = ($j == 0 ? '.' : '-') . $$rmorse;
        return 0;
      }
      elsif ($i % 2) {
        $$rmorse = '.' . $$rmorse;
        $i--;
      }
      else {
        $$rmorse = '-' . $$rmorse;
        $i -= 2;
      }
      $i /= 2;
    }
  }
  else {
    return 2;
  }
}


sub m2a($) {
  my $s      = shift;
  my $m      = '';
  my $ignore = 0;

  for (0..length($s)) {
    my $c = ($_ < length($s)) ? substr($s, $_, 1) : ' ';

    if (($ignore) && (($c eq ' ') || ($c eq '/'))) {
      $ignore = 2;
    }
    elsif ($ignore == 2) {
      $ignore = 0;
    }

    if ($ignore) {
      next;
    }

    my $rv    = 0;
    my $ascii = '';

    if ($c eq '.') {
      $rv = morse2ascii(0, 0);
      $m .= $c;
    }
    elsif ($c eq '-') {
      $rv = morse2ascii(1, 0);
      $m .= $c;
    }
    else {
      $rv = morse2ascii(-1, \$ascii);
      if ($rv == 0) {
        $m = '';
      }
    }

    if ($rv == 1) {
      print "[E$m]";
      morse2ascii(-1, 0);
      $m = '';
      $ignore = 1;
    }
    elsif ($rv == 2) {
      print "[?$m]";
      morse2ascii(-1, 0);
      $m = '';
      $ignore = 1;
    }
    elsif ($rv == 0) {
      print $ascii;
      if ($c eq '/') {
        print ' ';
      }
    }
  }
}


sub a2m($) {
  my $s = shift;
  my $pblnk = 0;

  for (0..length($s) - 1) {
    my $c     = substr($s, $_, 1);
    my $morse = '';

    if ($c eq ' ') {
      print '/';
      $pblnk = 0;
    }
    else {
      my $rv = ascii2morse($c, \$morse);
      if ($rv == 0) {
        if ($pblnk) { print ' '; }
        print "$morse";
        $pblnk = 1;
      }
      else {
        print '[?]'; 
      }
    }
  }
}


checkAsciiStr();

our ($opt_a, $opt_m);
exit 1 if !getopts('am');

my $s         = defined $ARGV[0] ? $ARGV[0] : "";
my $opt_ascii = defined $opt_a;
my $opt_morse = defined $opt_m;

sub translate() {
  if ($opt_morse) {
    m2a($s);
  }
  elsif ($opt_ascii) {
    a2m(uc($s));
  }
}

if ($s ne "") {
  translate();
}
else {
  while (<>) {
    chomp;
    $s = $_;
    translate();
  }
}

__END__

