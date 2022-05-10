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

for i in `grep ,$st,$tr carriersdb.csv`
do
  echo $i
  sat=`perl pickfield.pl 2 $i`
  trans=`perl pickfield.pl 3 $i`
  filename=$(echo scan-$sat-$trans.xml)
  echo $filename
  perl gen_demod_req.pl $sat $trans
  demodsetfile=("demodset-$sat-$trans*.xml")
  tsreadfile=("readts-$sat-$trans*.xml")
  echo $demodsetfile
  if [ ! -f $demodsetfile ]
  then
    echo Failed to create demod set XML file for $sat $trans.
    continue
  else
    demodsetfile=`ls $demodsetfile`
  fi

  if [ ! -f $tsreadfile ]
  then
    echo Failed to create tsread XML file for $sat $trans.
    continue
  else
    tsreadfile=`ls $tsreadfile`
  fi

  ipaddr=`echo $demodsetfile | sed "s/demodset-$sat-$trans-//" | sed 's/.xml//'`

  echo $ipaddr

  for j in 1 2 3
  do
    wget --post-file=$demodsetfile --http-user=configure --http-password=configure $ipaddr/BrowseConfig.pvr &> /dev/null
    echo Configuring demod try $j
    if grep '<ok \/>' BrowseConfig.pvr >/dev/null 
    then
      rm -f BrowseConfig.pvr
      break
    fi
    rm -f BrowseConfig.pvr
  done

  sleep 10

  for k in 1 2 3
  do
    echo Getting TS information try $k
    wget --post-file=$tsreadfile --http-user=configure --http-password=configure $ipaddr/BrowseConfig.pvr &> /dev/null
    if grep '<ok \/>' BrowseConfig.pvr >/dev/null 
    then
      mv BrowseConfig.pvr xml/$filename
      break
    fi
    rm -f BrowseConfig.pvr
  done
  rm -f $demodsetfile
  rm -f $tsreadfile
done
 

