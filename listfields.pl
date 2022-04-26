#!/usr/bin/perl
use strict;
use warnings;

use Path::Tiny;

use autodie; # die if problem reading or writing a file

open(my $fh, '<:encoding(UTF-8)', $ARGV[0])
  or die "Could not open station file $ARGV[0]\n";

my $line = <$fh>;

# Delete carriage return and line feed on this line.
$line =~ s/\n//g;
$line =~ s/\r//g;

my @fields = split(',',$line);
my $i=0;

for($i=0;$i<@fields;$i++) {

print "fields[$i] = $fields[$i]\n";

}
