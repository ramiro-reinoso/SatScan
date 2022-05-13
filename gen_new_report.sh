#!/bin/bash

# This shell script generates and sends the weekly report
# It also compares the weekly report to the previous weekly report
# and report on changes.

# Get the trasnport stream tables from the receivers for all carriers
# in the CarriersDb file
./scan.sh SES-1
./scan.sh SES-3
./scan.sh SES-11
./scan.sh AMC-11

# Generate the files with only the services names
./gen_program_files.sh

# Generate the report
./gen_xpr_report.sh

# Mail the report 

counter="1"
current_report=""
previous_report=""

for i in `ls -t reports/*`
do
  if [ $counter == "2" ]
  then
   echo Got the previous report filename.
   previous_report=$i
   break
  elif [ $counter == "1" ]
  then
   echo Got the current report filename.
   current_report=$i
   counter="2"
  fi

done

# Mail the report
echo "Transponder traffic report." | mail -s "Transponder Traffic Report" -A $current_report ramiro.reinoso@ses.com

# Mail the difference between current and previous reports
diff $previous_report $current_report | mail -s "Changes from previous report." ramiro.reinoso@ses.com

# Mail the list of transponders with no services
./check_services.sh |  mail -s "List of transponders without services" ramiro.reinoso@ses.com

