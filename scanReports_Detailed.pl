#!/usr/bin/perl

# This file extracts the Polygons from a modified KML file for urban areas
#

use 5.010;
use strict;
use warnings;

use XML::LibXML;
use Data::Types;

my $filename = $ARGV[0];
my @pidList = (0) x 10000;

my $dom = XML::LibXML->load_xml(location => $filename);

#print "Channel Name,Video Type,Video Bit Rate (bps),Channel Video Bit Rate (bps)\n";

foreach my $pids ($dom->findnodes('/hconf/get-status/filter/InputTs/InputService')) {

#print "$pids\n";
#my $pidNumber = $pids->findvalue('./attr/ServiceName');
my $pidNumber = 0;
my $serviceName = $pids->findvalue('./Attr/ServiceName');
print "Service Name = $serviceName\n";
my $bitRate = $pids->findvalue('./RATE-RAW');

$pidList[$pidNumber] = $bitRate;

#print "$pidNumber,$bitRate\n";

}

foreach my $channels ($dom->findnodes('/MPEG-TABLES/PMTs/CHANNEL')) {
#print "In loop\n";
my $channelName = $channels->findvalue('./SHORT-NAME');
$channelName =~ s/\n//g;
$channelName =~ s/\r//g;

my $totalBitRate = 0;
my $videoType = "Unknown";
my $videoPID = -99;

foreach my $elemStream ($channels->findnodes('./ELEMENTARY-STREAM')) { 

my $streamType = $elemStream->findvalue('./STREAM-TYPE');
my $tmpPID = $elemStream->findvalue('./PID');

#print "TMPPID: $tmpPID\n";

#$totalBitRate = $totalBitRate + $pidList[$tmpPID];
$totalBitRate = $totalBitRate + $pidList[$tmpPID];

if($streamType eq "VIDEO")
{
$videoType = $elemStream->findvalue('./VIDEO-TYPE');
print "$channelName,Video,$videoType,$pidList[$tmpPID]\n";
}

elsif($streamType eq "AUDIO")
{
my $audioLanguage=$elemStream->findvalue('./AUDIO-LANGUAGE');
print "$channelName,Audio,$audioLanguage,$pidList[$tmpPID]\n";
}

else
{
print "$channelName,Other,$streamType,$pidList[$tmpPID]\n";
}

}
print "$channelName,Total Bit Rate,$totalBitRate\n";
}

#print "PID,Bit Rate (bps)\n";

