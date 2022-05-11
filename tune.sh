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

for i in `grep ,$st,$tr CarriersDb.csv`
do
  sat=`perl pickfield.pl 2 $i`
  trans=`perl pickfield.pl 3 $i`
  filename=$(echo scan-$sat-$trans.csv)
  perl gen_demod_req.pl $sat $trans
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
 
