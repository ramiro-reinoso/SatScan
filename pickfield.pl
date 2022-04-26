#!/usr/bin/perl
use strict;
use warnings;

my $position = $ARGV[0];
my $line = $ARGV[1];

# Delete carriage return and line feed on this line.
$line =~ s/\n//g;
$line =~ s/\r//g;

my @fields = split(',',$line);

print "$fields[$position-1]";

