#!/bin/bash

# This shell script generates and sends the weekly report
# It also compares the weekly report to the previous weekly report
# and report on changes.

# Build the filename for the log file
today_month=$(date +"%b")
today_day=$(date +"%d")
today_year=$(date +"%Y")

log_file=$(echo logs/Report_"$today_month"-"$today_day"-"$today_year".log)

# Get the trasnport stream tables from the receivers for all carriers
# in the CarriersDb file
echo "Getting transport streams for SES-1" > $log_file
./scan.sh SES-1 >> $log_file
echo "Getting transport streams for SES-3" >> $log_file
./scan.sh SES-3 >> $log_file
echo "Getting transport streams for SES-11" >> $log_file
./scan.sh SES-11 >> $log_file
echo "Getting transport streams for AMC-11" >> $log_file
./scan.sh AMC-11 >> $log_file

# Generate the files with only the services names
echo "Generating the programs files from the XML files" >> $log_file
./gen_program_files.sh >> $log_file

# Generate the report >> $log_file
echo "Generating the final transponder traffic report" >> $log_file
./gen_xpr_report.sh >> $log_file

# Mail the report 

counter="1"
current_report=""
previous_report=""

for i in `ls -t reports/*`
do
  if [ $counter == "2" ]
  then
   echo Got the previous report filename. >> $log_file
   previous_report=$i
   break
  elif [ $counter == "1" ]
  then
   echo Got the current report filename. >> $log_file
   current_report=$i
   counter="2"
  fi

done

# Mail the report
echo "Mailing the transponder traffic report" >> $log_file
echo "Transponder traffic report." | mail -s "Transponder Traffic Report" -A $current_report ramiro.reinoso@ses.com >> $log_file

# Mail the difference between current and previous reports
sed -z 's/\n/,/g;s/,-/\n/g' $previous_report > temp1
sed -z 's/\n/,/g;s/,-/\n/g' $current_report > temp2
echo "Mailing the differences between the previous and current transponder traffic reports" >> $log_file
diff temp1 temp2 | mail -s "Changes from previous report." ramiro.reinoso@ses.com >> $log_file

# Mail the list of transponders with no services
echo "Mailing the list of transponders without any services" >> $log_file
./check_services.sh |  mail -s "List of transponders without services" ramiro.reinoso@ses.com >> $log_file

