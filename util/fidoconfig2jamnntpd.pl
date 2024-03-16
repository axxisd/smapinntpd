#!/usr/bin/perl
# 
# fidoconfig2jamnntpd.pl version 1.0 by Johan Billing
# This program has been released into the public domain, use it any way you want.
#

use Getopt::Long;

$getopt_res = GetOptions(\%opts, 'defaultgroup|g=s', 
                                 'defaultaka|a=s',
                                 'nonetmail|nn', 
                                 'nolocal|nl',
                                 'nobad|nb',
                                 'nodupe|nd',
                                 'help|h'  );
            
if ( !$getopt_res or $opts{help} or $#ARGV != 1) {
   print "\n";
   print "Usage: [perl] fidoconfig2jamnntpd.pl <crashmail.prefs> <jamnntpd.groups>\n";
   print "\n";
   print "Valid options are:\n";
   print "\n";
   print " --g=X  or --defaultgroup=X  Group for areas with unspecified group\n";
   print " --a=X  or --defaultaka=X    Aka for areas with unspecified aka\n";
   print " --nn   or --nonetmail       Do not include netmail areas in jamnntpd.groups\n";
   print " --nl   or --nolocal         Do not include local areas in jamnntpd.groups\n";
   print " --nb   or --nobad           Do not include bad area in jamnntpd.groups\n";
   print " --nd   or --nodupe          Do not include bad area in jamnntpd.groups\n";
   print " --h    or --help            Show this information\n";
   print "\n";
   
   exit (0);
}                   

$fidoconfig = $ARGV[0];
$groupsfile = $ARGV[1];

# Read config file

open (FIDOCONFIG, $fidoconfig) or die "Cannot open $fidoconfig";
open (GROUPSFILE, ">$groupsfile") or die "Cannot write to $groupsfile";

print GROUPSFILE "# Created from $fidoconfig by fidoconfig2jamnntpd.pl\n";
print GROUPSFILE "#\n";
print GROUPSFILE "# Some tweaking may be required.\n";
print GROUPSFILE "\n";

while (<FIDOCONFIG>) {
   s/\s+$//; # strip trailing whitespace

   if ( ! /^#/ ) {
      @words = split('\s+',$_);

      if ( ( lc($words[0]) eq 'echoarea' ) or
           ( lc($words[0]) eq 'localarea' and !$opts{nolocal} ) or
           ( lc($words[0]) eq 'badarea' and !$opts{nobad} ) or
           ( lc($words[0]) eq 'dupearea' and !$opts{nodupe} ) or
           ( ( lc($words[0]) eq 'netarea' or lc($words[0]) eq 'netmailarea' ) and !$opts{nonetmail} ) ) {
         
         @args = ();
         
         $type = 'Msg';
         $aka = '';
         $group = '';
                               
         for ( $i = 1; $i <= $#words; $i++ ) {
            if ($words[$i] eq '-b' ) {
               $type = $words[++$i];
            }
            elsif ($words[$i] eq '-a' ) {
               $aka = $words[++$i];
            }
            elsif ($words[$i] eq '-g' ) {
               $group = $words[++$i];
            }
            else {
               push(@args, $words[$i]);
            }
         }

         if ( !$group ) {
            $group = $opts{defaultgroup};
         }

         if ( !$group ) {
            $group = '""';
         }
                  
         if ( !$aka ) {
            $aka = $opts{defaultaka};
         }
         
         if ( !$aka ) {
            $aka = '0:0/0.0';
         }
        
         if ( $args[0] and $args[1] and $args[1] ne 'passthrough' ) {
            if (lc($type) eq 'jam' ) {
               $area = $args[0];
  
               if ( lc($words[0]) eq 'netarea' or lc($words[0]) eq 'netmailarea' ) {
                  $area = '!'.$area;
               }
               elsif ( lc($words[0]) eq 'localarea' ) {
                  $area = '$'.$area;
               }
               
               printf GROUPSFILE ("%-30s %-3s %-15s %s\n",$area,$group,$aka,$args[1]);
            }
            else {
               print "Warning: Area $args[0] is not a JAM area, skipping...\n";
            }
         }
      }
   }      
}
    
close (FIDOCONFIG);
close (GROUPSFILE);


