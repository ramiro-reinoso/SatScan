#!/bin/bash

# Check and make sure a parameter was passed

if [[ $# -eq 0 ]] ; then
    echo 'Usage: scan-h.sh [SES-1 or SES-3 or SES-11 or AMC_11]'
    echo 'For example, scan-h.sh SES-1 to scan SES-1 programs'
    exit -1
fi

if [[ ($1 == 'SES-1') || ($1 == 'SES-11') || ($1 == 'SES-3') || ($1 == 'AMC-11') ]]
then
    st=$(echo $1)
else
    echo 'Satellite not found.  Check spelling and upper and lower case settings.'
    exit -1
fi

if [ -n "$2" ]
then
    tr=$(echo $2,)
fi

# Create a database without spaces to avoid confusing the CSV parser

sed 's/ /_/g' CarriersDb.csv > temp_carriersdb.csv

found="0"

for i in `grep ,$st,$tr temp_carriersdb.csv`
do
  found="1"
  sat=`perl pickfield.pl 2 $i`
  trans=`perl pickfield.pl 3 $i`
  filename=$(echo scan-$sat-$trans.csv)
  perl gen_demod_req.pl $sat $trans

  # Check for any error codes from the demodulation request generator
  # and take appropriate action upon errors

  retVal=$?
  if [ $retVal -eq 1 ]
  then
     echo "Carrier not tagged for scanning."
     continue
  elif [ $retVal -eq 2 ]
  then
     echo "Cannot PVR configuration for this carrier."
     continue
  elif [ $retVal -eq 3 ]
  then
     echo "Carrier not found in carrier database."
     continue
  fi

  demodsetfile=("demodset-$sat-$trans*.xml")
  tsreadfile=("readts-$sat-$trans*.xml")

  if [ ! -f $demodsetfile ]
  then
    echo Failed to create demod set XML file for $sat $trans.
    continue
  else
    demodsetfile=`ls $demodsetfile`
  fi

  ipaddr=`echo $demodsetfile | sed "s/demodset-$sat-$trans-//" | sed 's/.xml//'`

  for j in 1 2 3
  do
    wget --post-file=$demodsetfile --http-user=configure --http-password=configure $ipaddr/BrowseConfig.pvr &> /dev/null
    echo $j
    if grep '<ok \/>' BrowseConfig.pvr >/dev/null 
    then
      rm -f BrowseConfig.pvr
      break
    fi
    rm -f BrowseConfig.pvr
  done

  echo $sat-$trans tuned on PVR $ipaddr

  rm -f $demodsetfile
  rm -f $tsreadfile
done
 
if [ $found == "0" ]
then
  echo "Carrier not found in the database"
fi


