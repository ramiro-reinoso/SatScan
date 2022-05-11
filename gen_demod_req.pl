#!/usr/bin/perl

# This script generates two XML files:
#
# (1) One to tune the Harmonic receiver demodulator to the carrier
# (2) One to read the transport stream from the Harmonic receiver
#
# It take as arguments the satellite and the transponder name
# It uses the carrier database "CarrierDb.csv" to find the carrier configuration parameters
# and the "pvr-index.csv" file to determine the IP address and the RF port number that
# needs to be tuned to lock onto the carrier, as well as the input multiplexer to use
# for retrieving the transport stream information


# Start with some Perl global configuration options
use strict;
use warnings;
use Path::Tiny;
use autodie; # die if problem reading or writing a file

# This file contains the carrier database
my $carrierdb = "/home/uhd-lab/Documents/Harmonic_xml/programs-2/carriers-list/CarriersDb.csv";

# This file contains the PVR configurations in the lab
my $pvrdb = "/home/uhd-lab/Documents/Harmonic_xml/programs-2/carriers-list/pvr-index.csv";

# Check that the correct number of parameters were passed to the application
if($#ARGV != 1) {
print "This program requires two arguments: satellite name (SES-1, SES-3, SES-11, AMC-11) and transponder name.\n";
exit(-1);
}

# Assign the two parameters to variables
my $satellite = $ARGV[0];
my $carrier = $ARGV[1];

# Open the carrier database file to search for desired carrier parameters
open(my $fh, '<:encoding(UTF-8)', $carrierdb)
  or die "Could not open carriers file $carrierdb\n";

# Read the file heading however the header is of no use for this script
my $header = <$fh>;

# Declare variables
my $success = 0;
my $pvripaddr = "";
my $rfport = 0;
my $symbolrate = 0;
my $lbandfreq = 0;

# Start a loop to read the CarriersDb file one line at a time
while(my $line = <$fh>)
{
  # Delete carriage return and line feed on this line.
  $line =~ s/\n//g;
  $line =~ s/\r//g;

  # Break up the line into its fields
  my @fields = split(',',$line);

  # Check for video carrier flag and if not a video carrier then get the next line
  if ($fields[11] eq 'N') {next;}

  # Test if there is a match for the satellite and carrier
  # If there is match, extract the carrier parameters
  if (($fields[1] eq $satellite) && ($fields[2] eq $carrier))
  {
    my $polarization = $fields[10];
    $lbandfreq = $fields[3]/1000;
    $symbolrate = $fields[8];
    
    # Open the file pvrdb to find the PVR to use
    open(my $fh2, '<:encoding(UTF-8)', $pvrdb)
      or die "Could not open station file $pvrdb\n";

    # Inspect line by line to find the IP address and the address port to use
    # for locking to this carrier
    while(my $line2 = <$fh2>)
    {
       # Delete carriage return and line feed on this line.
       $line2 =~ s/\n//g;
       $line2 =~ s/\r//g;

       # Break up the line into its fields
       my @fields2 = split(',',$line2);

       # If there is a match then extract the IP address and port
       if(($fields2[1] eq $satellite) && ($fields2[2] eq $polarization))
       {
           $rfport = $fields2[4];
           $pvripaddr = $fields2[3];
           $success = 1;
           last;
       }
     }
     close($fh2);
    
     # If no match was found, print out a warning message and exit
     if ($success == 0)
     {
       print "Could not find PVR configured for $satellite or carrier $carrier is not a video carrier.\n";
       exit(-1);
     }

     # Since we found a match in the carrier database and we found a PVR to use then there his no need
     # to continue searching for a carrier match in the CarriersDb file. We are done and it is time to
     # break the outer loop 
     last;
   }
}

close($fh);


# If no carrier was found in the CarriersDb then quit the script
if ($success == 0)
{
   print "Could not find $carrier configured for this satellite.\n";
   exit(-1);
}

# Define the filenames for the XML configuration files  using the satellite and transponder names
my $setmodxml = "demodset-${satellite}-${carrier}-${pvripaddr}.xml";
my $readtsxml = "readts-${satellite}-${carrier}-${pvripaddr}.xml";

# Create the XML file to configure the PVR decoder for output

open(my $fh3, '>:encoding(UTF-8)', $setmodxml)
  or die "Could not open station file $setmodxml\n";

# Print the contents of the XLM demodulator configuration file

print $fh3 "<hconf xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" source=\"Viewer\" xsi:noNamespaceSchemaLocation=\"./hconf.xsd\">\n";
print $fh3 "<edit-config>\n";
print $fh3 "<edit pass-through=\"false\">\n";
print $fh3 "<AravaPortV1 Id=\"1300000${rfport}\" SuperClassId=\"11\">\n";
print $fh3 "<Attr>\n";
print $fh3 "<!--DVB-S(0) DVB-S2(1) Automatic(2)-->\n";
print $fh3 "<ModulationStandard>2</ModulationStandard>\n";

# Print the correct symbol rate for this carrier
print $fh3 "<SymbolRate>${symbolrate}</SymbolRate>\n";

# Print to file the L-Band frequency of the carrier
print $fh3 "<!--LBand Frequency=Universal Frequency-LnbLoFreq(9,750,000|10,600,000)-->\n";
print $fh3 "<LBandFreq>${lbandfreq}</LBandFreq>\n";
print $fh3 "</Attr>\n";
print $fh3 "</AravaPortV1>\n";
print $fh3 "</edit>\n";
print $fh3 "</edit-config>\n";
print $fh3 "</hconf>\n";

close($fh3);

# Create the XML file to retrieve the transport stream tables

open(my $fh4, '>:encoding(UTF-8)', $readtsxml)
  or die "Could not open station file $readtsxml\n";

# Print the entries of the XLM configuration file to retrieve transport stream information

print $fh4 "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print $fh4 "<hconf source=\"Viewer\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"./hconf.xsd\">\n";
print $fh4 "<get-status>\n";
print $fh4 "<filter type=\"subtree\" include_comments=\"true\" pass-through=\"false\">\n";
print $fh4 "<InputTs Id=\"7000000${rfport}\"/>\n";
print $fh4 "</filter>\n";
print $fh4 "</get-status>\n";
print $fh4 "</hconf>\n";

close($fh4);
