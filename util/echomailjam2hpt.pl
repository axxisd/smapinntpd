#!/usr/bin/perl
# 
# echomailjam2hpt.pl version 1.1 by Johan Billing
# This program has been released into the public domain, use it any way you want.
#
# Converts an echomail.jam file to the format used by hpt

use Text::ParseWords;

sub readfidoconfig
{
   local $fidoconfig = $_[0];

   print "Reading $fidoconfig...\n";

   open (FIDOCONFIG, $fidoconfig) or die "Cannot open $fidoconfig";

   while (<FIDOCONFIG>) {
      s/\s+$//; # strip trailing whitespace

      if ( ! /^#/ ) {
         @words = quotewords('\s+', 1, $_);

         foreach( @words ) {
            $_ =~ s/["]//g;
         }

         if( lc($words[0]) eq 'include' ) {
            readfidoconfig($words[1]);
         }
         elsif ( lc($words[0]) eq 'echoarea' or 
              lc($words[0]) eq 'localarea' or
              lc($words[0]) eq 'badarea' or 
              lc($words[0]) eq 'dupearea' or
              lc($words[0]) eq 'netarea' or 
              lc($words[0]) eq 'netmailarea' ) {
         
            $type = '';
                               
            for ( $i = 1; $i <= $#words; $i++ ) {
               if ($words[$i] eq '-b' ) {
                  $type = $words[++$i];
               }
            }

            if ( $words[1] and $words[2] and lc($words[2]) ne 'passthrough' and lc($type) eq 'jam') {
               $pathtoarea{$words[2]} = $words[1];
            }            
         }
      }
   }

   close (FIDOCONFIG);
}

if ( $#ARGV != 2) {
   print "Usage: [perl] echomailjam2hpt.pl <echomail.jam> <fidoconfig> <echotoss.log>\n";
   exit 0;
}                   

$echomailjam = $ARGV[0];
$fidoconfig  = $ARGV[1];
$echotosslog = $ARGV[2];

# Read echomail.jam

print "Reading $echomailjam...\n";

if( !open(ECHOMAILJAM, $echomailjam)) {
   print "$echomailjam not found, nothing to do.\n";
   exit 0;
}

while (<ECHOMAILJAM>) {
   s/\s+$//; # strip trailing whitespace
   @words = split('\s+',$_);

   if($words[0]) {
      $areas{$words[0]} = '';
   }
}

close (ECHOMAILJAM);

if ( ! ( keys %areas) ) {
   print "$echomailjam is empty, nothing to do.\n";
   exit 0;
}

# Read fidoconfig

readfidoconfig($fidoconfig);

# Write echotosslog
    
print "Appending to $echotosslog...\n";

open (ECHOTOSSLOG, ">>$echotosslog") or die "Cannot write to $echotosslog";

foreach $path (keys %areas)
{
   if ( $pathtoarea{$path} ) {
      print ECHOTOSSLOG "$pathtoarea{$path}\n";
   }
   else
   {
      print "WARNING: Path $path not found in $fidoconfig, skipping area\n";
   }
}

close (ECHOTOSSLOG);
