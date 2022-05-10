#!/usr/bin/perl

# This file generates the monthly report
# It takes as an argument the carrier database file
#

use strict;
use warnings;

use Path::Tiny;

use autodie; # die if problem reading or writing a file

open(my $fh, '<:encoding(UTF-8)', $ARGV[0])
  or die "Could not open station file $ARGV[0]\n";

# Read the file heading and put it in the stdout
my $line = <$fh>;

# Delete carriage return and line feed on this line.
$line =~ s/\n//g;
$line =~ s/\r//g;

my @fields = split(',',$line);

# Print the report heading

print "$fields[0],$fields[1],$fields[2],$fields[10],$fields[3],$fields[4],$fields[12],$fields[13],Video Programs\n";

# Process one line at a time until the EOF

while(my $line = <$fh>)
{
  # Delete carriage return and line feed on this line.
  $line =~ s/\n//g;
  $line =~ s/\r//g;

  my @fields = split(',',$line);

  # Print all but the Video Services
  print "$fields[0],$fields[1],$fields[2],$fields[10],$fields[3],$fields[4],$fields[12],$fields[13],";

  # Build the file name where the services (if any) are listed
  my $prog_list_file="programs/scan-$fields[1]-$fields[2].csv";

  my $empty=1;

  if (-e $prog_list_file) 
  {
    open(my $fh2, '<:encoding(UTF-8)', $prog_list_file)
       or die "Could not open station file $ARGV[0]\n";
    
    if (defined(my $progline = <$fh2>))
    {
         $empty = 0;
         $progline =~ s/\n//g;
         $progline =~ s/\r//g;

         print "\"$progline";
    }
    
    while(my $progline = <$fh2>)
    {
       $empty = 0;
       $progline =~ s/\n//g;
       $progline =~ s/\r//g;
       print "\n$progline";
    }

    if (! $empty)
    {
       print "\"\n";
    }
    else
    {
       print "\n";
    }

    close($fh2);
  } 
  else 
  {
    print "\n";
  }
}

close($fh);
