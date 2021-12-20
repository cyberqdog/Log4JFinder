#!/bin/bash
# This script attempts to locate all jar files starting at and below the directory
# specified via the argument list.
# Usage: java_lib_list -c -w -h <hostname> -i <ipaddress> -s <starting_dir>
#        where:    
#         -c is used to also list the contents of the jar file. (note: jar command must be in path)
#         -h is used to set the hostname for the report, otherwise uses hostname command for hostname.
#         -i is used to set ip address for the report, otherwise uses 'hostname -I'
#         -s is used to set the starting directory

# Get hostname and IP address
hostname=`hostname`
hostIp=`hostname -I | sed 's/ *$//g'`
header="hostname, IP, library, version, fileName, fileSize, md5, directory"

while getopts 'ch:i:s:' OPTION; do
    case "$OPTION" in
        c)
            header="hostname, IP, library, version, fileName, fileSize, md5, directory, bytecodFileName"
            contents=1
            if ! hash jar 2>/dev/null; then
                echo "-c optioin requires that the jar be in the path. jar not found. Exiting."
                exit 
            fi
            ;;
        h)
            hostname=${OPTARG}
            echo "setting hostname to $hostname"
            ;;
        i)
            hostIp="$OPTARG"
            ;;
        s)
            startDir="$OPTARG"
           ;;
        *)
            echo "Usage: $0 [-c] [-i IP for csv] [-h hostname for csv] -s <start directory>" >&2
            exit 1
        ;;
    esac
done

if [[ -z "$startDir" ]]
then
    echo "Usage: $0 [-c] [-i IP for csv] [-h hostname for csv] -s <start directory>" >&2
    echo "       Use -c Include jar file contents in report"
    echo "       Start directory must be set using the -s argument."
    exit -1
else
    if [[ ! -d ${startDir} ]]
    then
        echo "Start directory: ${startDir} not found. Exiting."
        exit -1
    fi
fi

# Find all the jar files and save the paths
export jarfiles=`find ${startDir} -name '*.jar' -print`


# Get the info from all of the jar file we found
for fullPathToJarFile in ${jarfiles}
do
  # Get the file size
  fileSizeBytes=`du -b "${fullPathToJarFile}" | cut -f1`    

  # Get the MD5 sum of the file
  sum=`md5sum ${fullPathToJarFile} | awk {'print $1'}`

  # Extract the directory name
  dirName="$(dirname "${fullPathToJarFile}")"

  # extract the file name
  fileName="$(basename "${fullPathToJarFile}")"

  # Attempt to obtain a library name and a version number from the file name
  [[ $fileName =~ (.*)[-_]([0-9\.]+)\.jar ]]
  libName=${BASH_REMATCH[1]:-0}
  version=${BASH_REMATCH[2]:-0}

  if [[ -n ${contents} ]]
  then
     byteCodeFiles=`jar -tf ${fullPathToJarFile}`
     for byteCodeFile in ${byteCodeFiles}
     do
     echo ${hostname:-unset},  \
          ${hostIp:-unset},    \
          ${libName:-unset},   \
          ${version:-unset},   \
          ${fileName:-unset},  \
          ${fileSizeBytes:-0}, \
          ${sum:-0},           \
          ${dirName:-unset}     \
	  ${byteCodeFile:-unset}
     done
  else
     echo ${hostname:-unset},  \
          ${hostIp:-unset},    \
          ${libName:-unset},   \
          ${version:-unset},   \
          ${fileName:-unset},  \
          ${fileSizeBytes:-0}, \
          ${sum:-0},           \
          ${dirName:unset}
  fi
done
