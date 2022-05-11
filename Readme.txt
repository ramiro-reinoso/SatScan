Toolkit to tune the PVR demodulators and to read the transport stream tables from teh PVR receiver

- scan.sh.  This shell script takes one or two arguments (satellite name and transponder name) to tune the PVR receiver to the
carrier on that transponder, wait for a lock, read the transport stream tables, and store the results in an XML file in the 
"xml" folder.  The name of the file will be "scan-<satellite name>-(transponder name>.xml".  If the script is invoked with only
one parameter, it will scan all the transponders in the CarriersDb.csv file.  If the script is invoked with both parameters,
the script will scan only that one transponder.

- tune.sh.  This shell script will tune the PVR to a carrier.  It takes two arguments, satellite name and transponder name.  It 
then provides the IP address of the PVR that has been configured to lock on the carrier.

- checkservices.sh.  This script checks the transport stream XML files and provides the name of the satelite and transponder with
no service names or blank service names.  This is usually the case when the transport stream does not follow standard tables 
configurations.  For those carriers without service names, a more manual process using a transport stream analyzer must be used.

- gen_program_files.sh.  This script process all the XML files in the xml folder, extracts the services names in the transport stream,
and creates a file with a list of the service names.  The files are placed in the programs folder and their names use this format, 
scan-<satellite name>-<transponder name>.csv.


