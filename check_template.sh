#!/bin/sh
#
# <...> plugin for Nagios
# Written by <...>
# Template by: Lily <djlilis@yahoo.com>
# Inspired by: I forgret but probably the Nagios community
# Last Modified: <...>
#
# Usage: ./check_name <required argument> <required argument> ...
#
# Description:
#
# This plugin will <...>
#
# Output:
#
# <...>
#
# Notes:
#
# <...>
#
# Examples:
#
# Check for <x>
#
# check_name <arg1> <arg2>
#
# Check for <y>
#
# check_name <arg3> <arg4> <arg5>
#

# Sanitize paths for security. Need to be adjusted per OS.
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Alternatively, specify absolute paths 
#GREP="/bin/egrep"
#DIFF="/bin/diff"
#TAIL="/bin/tail"
#CAT="/bin/cat"
#RM="/bin/rm"
#CHMOD="/bin/chmod"
#TOUCH="/bin/touch"

# Name of this file in to PROGNAME
PROGNAME=`/bin/basename $0`

# Path to this file in to PROGPATH
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`

REVISION="1"

# Source the Nagios utility scripts (part of nagios-plugins)
. $PROGPATH/utils.sh

# usage() - uses PROGNAME, spits out breif help for command.
print_usage() {
    echo "Usage: $PROGNAME -F logfile -O oldlog -q query"
    echo "Usage: $PROGNAME --help"
    echo "Usage: $PROGNAME --version"
}

# help - uses PROGNAME, REVISION, spits out detailed help for command.
print_help() {
    print_revision $PROGNAME $REVISION
    echo ""
    print_usage
    echo ""
    echo "Log file pattern detector plugin for Nagios"
    echo ""
    support
}

# Make sure the correct number of command line
# arguments have been supplied, if this can be known beforehand.

if [ $# -lt 1 ]; then
    print_usage
    exit $STATE_UNKNOWN
fi

# Parse options. It's nice to support common help style options, as
# well as common Nagios options.
# --help|-h for help,
# --version|-V for version,
# -t for socket timeouts,
# -w for warning threshold,
# -c for critical threshold

exitstatus=$STATE_WARNING #default
while test -n "$1"; do
    case "$1" in
        --help|-h)
            print_help
            exit $STATE_OK
            ;;
        --version|-V)
            print_revision $PROGNAME $REVISION
            exit $STATE_OK
            ;;
        --argument|-A)
            argument=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

# check logic goes here.



exit $exitstatus
