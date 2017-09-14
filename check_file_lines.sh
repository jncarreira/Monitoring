#!/bin/bash

# # # - - -
# check_file_lines.sh
# -
# Release date:	Sep 14 2017
# Author:		THOMAS.ORTH@CZ.IBM.COM
# Version:		1.0
# - 
# Description:	Nagios plugin to check if any new lines appeared in the file.
#				
# - 
# Version notes:
#				
# # # - - -

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`

# # # - - -
# Usage:		$PROGPATH/$PROGNAME --file|-f <file> --position|-p <position_file> --help|-h 
#
# # # - - -

print_usage () {
	echo "- Usage:      $PROGPATH/$PROGNAME --file|-f <file> [--position|-p <position_file>]"
	echo "-             $PROGPATH/$PROGNAME --help|-h"
	}

# - - -
# Variables
# - - -

# Defining return codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Chech if at least one position variable is present
if [ $# -lt 1 ]
then
    print_usage
    exit $STATE_UNKNOWN
fi

# Loading Arguments
while test -n "$1"; do
    case "$1" in
        --file|-f)
            export MONITORED_FILE="$2"
            shift
            ;;
        --position|-p)
			# By default position file is created in the directory where the original <file> is located with naming convention <file>.position
            export POSITION_FILE="$2"
            shift
            ;;
        --help|-h)
            print_usage
            exit $STATE_OK
            ;;
        *)
            echo "Unknown argument: $*"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

# - - -
# MAIN
# - - -

# Check if the monitored file exists
if [ ! -e $MONITORED_FILE ]
then
    echo "File check error: File "$MONITORED_FILE" does not exist!"
    exit $STATE_CRITICAL
elif [ ! -r $MONITORED_FILE ]
then
    echo "File check error: File "$MONITORED_FILE" is not readable!"
    exit $STATE_CRITICAL
else
	if [ -z $POSITION_FILE ]
	then
		export POSITION_FILE=$MONITORED_FILE".position"
	fi
fi

# Number of current lines
export CURRENT=$(cat $MONITORED_FILE | wc -l)

# Check if the position file already exists. If not - set to default.
if [ ! -e $POSITION_FILE ]
then
    echo $CURRENT > $POSITION_FILE
    echo "OK - File check data initialized. - "$MONITORED_FILE
    exit $STATE_OK
fi

# Number of previous lines
export PREVIOUS=$(cat $POSITION_FILE)

# Compare number of lines of file with position file
if [ $CURRENT -gt $PREVIOUS ]
then
	echo "CRITICAL - "$(($CURRENT-$PREVIOUS))" new line/s appeared. - "$MONITORED_FILE
	echo $CURRENT > $POSITION_FILE
	exit $STATE_CRITICAL
else
	echo "OK - No new lines. - "$MONITORED_FILE
	echo $CURRENT > $POSITION_FILE
	exit $STATE_OK
fi
