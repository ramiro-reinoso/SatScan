#!/bin/bash

# This script extracts the services from the XML files and create files
# with a list of services on that transponder

for i in `ls xml/*`
do
echo Processing $i

filename=$(echo $i | sed 's/.xml/.csv/' | sed 's/^xml/programs/')

perl scanReports_NameOnly.pl $i > $filename

done

