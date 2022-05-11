#!/bin/bash

today_month=$(date +"%b")
today_day=$(date +"%d")
today_year=$(date +"%Y")

filename=$(echo reports/Transponder_Scan_Report_"$today_month"-"$today_day"-"$today_year".csv)

echo "Building transponder scan report to file $filename"

perl gen_report.pl CarriersDb.csv > $filename
