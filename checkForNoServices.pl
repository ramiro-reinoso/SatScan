#!/usr/bin/perl

# This file extracts the Polygons from a modified KML file for urban areas
#

use 5.010;
use strict;
use warnings;

use XML::LibXML;
use Data::Types;

my $filename = $ARGV[0];

my @fields = split('-',$filename);
my $satellite = "$fields[1]-$fields[2]";
my $transponder = $fields[3];
$transponder =~ s/.xml//;

my @pidList = (0) x 10000;

my $dom = XML::LibXML->load_xml(location => $filename);

#print "Channel Name,Video Type,Video Bit Rate (bps),Channel Video Bit Rate (bps)\n";

my $emptyflag = 0;

foreach my $service ($dom->findnodes('/hconf/get-status/filter/InputTs/InputService')) {

   my $serviceName = $service->findvalue('./Attr/ServiceName');

   if($serviceName ne '')
   {
      $emptyflag = 1;
   }

}

if($emptyflag == 0)
{
   print "$satellite,$transponder,N\n";
}
else
{
   print "$satellite,$transponder,Y\n";
}

