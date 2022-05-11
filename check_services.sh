#!/bin/bash

# This script check the XML transport stream files for those that do not have
# service names and lists the ones without service names 

for i in `ls xml/*`
do

perl checkForNoServices.pl $i | grep N

done

