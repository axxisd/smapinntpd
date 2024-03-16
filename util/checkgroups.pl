#!/usr/bin/perl
# 
# checkgroups.pl version 1.0 by Johan Billing
# This program has been released into the public domain, use it any way you want.
#
# This program reads a JamNNTPd configuration file and checks that all listed 
# messagebases are in order. If run with the --fix switch, it will create 
# missing messagebases and lastread files (*.jlr).

use Time::Local;
use Time::Timezone;
use Text::ParseWords;
use Getopt::Long;

$getopt_res = GetOptions(\%opts, 'fix','help|h');
                                 
if ( !$getopt_res or $opts{help} or $#ARGV != 0) {
   print "Usage: checkgroups.pl [--fix] <jamnntpd.groups>\n";
   exit 0;
}

open (GROUPSFILE, $ARGV[0]) or die "Cannot open $ARGV[0]";

while (<GROUPSFILE>) {
   s/\s+$//; # strip trailing whitespace

   if ( ! /^#/ ) {
      @words = quotewords('\s+', 1, $_);
      $basename = $words[3];
  
      if ($basename) {    
         $jdxfile = $basename . ".jdx";
         $jhrfile = $basename . ".jhr";
         $jdtfile = $basename . ".jdt";
         $jlrfile = $basename . ".jlr";

         $hasjdx = (-e $jdxfile);
         $hasjhr = (-e $jhrfile);
         $hasjdt = (-e $jdtfile);
         $hasjlr = (-e $jlrfile);

         if(!$hasjdx and !$hasjhr and !$hasjdt and !$hasjlr) {
            print "Messagebase $basename is missing\n";

            if( $opts{fix} ) {
               print " Creating missing messagebase $basename\n";
               
               open(JDX,">$jdxfile") or die "Failed to open $jdxfile";
               open(JHR,">$jhrfile") or die "Failed to open $jhrfile";
               open(JDT,">$jdtfile") or die "Failed to open $jdtfile";
               open(JLR,">$jlrfile") or die "Failed to open $jlrfile";

               $unixtime = time-timegm(0, 0, 0, 1, 0, 70)+tz_local_offset();
               print JHR pack("Z[4]LLLLLx[1000]",'JAM',$unixtime,0,0,0xffffffff,1);

               close(JDX);
               close(JHR);
               close(JDT);
               close(JLR);
            }
         }
         elsif($hasjdx and $hasjhr and $hasjdt and !$hasjlr) {
            print "Lastread file is missing for $basename\n";
   
            if( $opts{fix} ) {
               print " Creating missing .jlr file for $basename\n";
               
               open(JLR,">$jlrfile") or die "Failed to open $jlrfile";
               close(JLR);
            }
         }
         else {
            if(!$hasjdx) {
               print ".jdx file is missing for $basename\n";
            }
            if(!$hasjhr) {
               print ".jhr file is missing for $basename\n";
            }
            if(!$hasjdt) {
               print ".jdt file is missing for $basename\n";
            }
            if(!$hasjlr) {
               print ".jlr file is missing for $basename\n";
            }
         }
      }
   }
}

close(GROUPSFILE);
