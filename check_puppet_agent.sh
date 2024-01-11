#!/bin/sh
#
# Puppet agent plugin for Nagios
# Written(?) by Lily
# Possibly from?:
# https://github.com/aswen/nagios-plugins/blob/a55a5b1dbd0501070c312583f1b622e617b3f4fc/check_puppet_agent
#
# Last Modified: 6/19/2014
#
# Usage: ./check_puppet_agent
#
# Description:
#
# This plugin, when configured correctly, will check to make sure puppet is in the
# expected location, is running as a service, the last run was within a specified 
# timespan, and no errors or warnings were logged during the last run. Additionally,
# performance data is returned.
#
# Output:
#
# <...>
#
# Notes:
#
# The plugin requires the utils.sh script from Nagios, and expects to be
# in the same directory as it. The script needs to be called with a 
# directory component (example, ./check_puppet_agent.sh) so it can find
# the directory the script is in from the command argument and then find
# the utils.sh script.
#
# Examples:
#
# Check Puppet agent
#
# ./check_name
#
# Check Puppet agent, with a WARN time of 5 min and CRIT time of 10 min.
#
# ./check_name -w 300 -c 600
#

# Sanitize paths for security. Needs to be adjusted per OS.
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Constants 
# PIDFILE: the file for the running Puppet pid.
#   Puppet can be asked for this, but RedHat specifies a separate one
#   on the command line in the init script, so that can't be trusted 
#   by a command line run.
PIDFILE="/var/run/puppet/agent.pid"

# PUPPET: where's puppet found?
#   Usually '/usr/bin/puppet', with a sudo in front
PUPPET="/usr/bin/puppet"

# PUPPET_CMD: And are we running it via sudo?
PUPPET_CMD="sudo ${PUPPET}"

# Name of this file in to PROGNAME
PROGNAME=$(/bin/basename $0)

# Path to this file in to PROGPATH
PROGPATH=$(echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,')

REVISION="1"

# Source the Nagios utility scripts (part of nagios-plugins)
. $PROGPATH/utils.sh

# usage() - uses PROGNAME, spits out breif help for command.
print_usage() {
    echo "Usage: $PROGNAME"
    echo "       $PROGNAME --help"
    echo "       $PROGNAME --version"
}

# help() - uses PROGNAME, REVISION, spits out detailed help for command.
print_help() {
    print_revision $PROGNAME $REVISION
    echo ""
    print_usage
    echo ""
    echo "Puppet agent plugin for Nagios"
    echo ""
    support
}

# yaml parser. Give it a file, and it spits out text to be eval'ed.
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Start here

# Parse options. It's nice to support common help style options, as
# well as common Nagios options.
# --help|-h for help,
# --version|-V for version,
# -t for socket timeouts,
# -w for warning threshold,
# -c for critical threshold

# Start with CRIT set to 1 hr and WARN set to 30 min (in seconds)
CRIT=3600
WARN=1800

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
        --warn|-w)
            WARN=$2
            shift
            ;;
		--crit|-c)
            CRIT=$2
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

# Check, can we actually find Puppet on this system?
if [ ! \( -x ${PUPPET} \) ] ; then
  echo "Agent unknown: Puppet missing."
  exit ${STATE_UNKNOWN}
fi

# Check, has puppet ever run?
LASTRUNFILE=$(${PUPPET_CMD} config print lastrunfile)
# If LASTRUNFILE exists, has data in it and is readable, continue, otherwise exit
if ! ( [ -s ${LASTRUNFILE} ] && [ -r ${LASTRUNFILE} ] ) ; then
  echo "Agent unknown: Puppet last run summary not found, not readable, or corrupted."
  exit ${STATE_UNKNOWN}
fi

# Check, is daemon running?
if [ -z "$(ps ax | grep "/usr/bin/ruby /usr/bin/puppet agent" | grep -v "grep")" ]  ; then
  echo "Agent critial: Agent not running."
  exit ${STATE_CRITICAL}
fi

# Parse the summary file for use later.
eval $(parse_yaml ${LASTRUNFILE} "PRUN")

# Check, last run time within thresholds?
### Get time now,
NOW=$(date +%s)

### Calculate time in seconds from last run.
HOWLONGSECS=$((NOW-PRUN_time_last_run))

### Compare to CRIT, exit accordingly
if [ ${HOWLONGSECS} -ge ${CRIT} ] ; then
  echo "Agent critical: Last run ${HOWLONGSECS} secs ago. (CRIT=${CRIT})"
  exit ${STATE_CRITICAL}
fi

### Compare to WARN, exit accordingly
if [ ${HOWLONGSECS} -ge ${WARN} ] ; then
  echo "Agent warning: Last run ${HOWLONGSECS} secs ago. (WARN=${WARN})"
  exit ${STATE_WARN}
fi

# Check, were there errors in the last run?
### Where is the lastrunreport?
LASTRUNREPORT=$(${PUPPET_CMD} config print lastrunreport)

### Check, does lastrunreport exist?
if ! ( [ -s ${LASTRUNREPORT} ] && [ -r ${LASTRUNREPORT} ] ) ; then
  echo "Puppet last run report not found, not readable, or corrupted."
  exit ${STATE_UNKNOWN}
fi

### If file exists, collate errors
LASTRUNCRIT=$(grep -e "^ *level:" ${LASTRUNREPORT} | egrep -e "err|alert|emerg|crit" | wc -l)
if [ ${LASTRUNCRIT} -gt 0 ] ; then
  echo "Agent critical: Last run had ${LASTRUNCRIT} error(s)."
  exit ${STATE_CRITICAL}
fi

### Check for other errors from the statistics.
if [ ${PRUN_resources_failed} -gt 0 ] || [ ${PRUN_events_failure} -gt 0 ] || [ ${PRUN_resources_failed_to_restart} -gt 0 ] ; then
  echo "Agent critical: failure during last run."
  exit ${STATE_CRITICAL}
fi

### If there were no errors, collate the warnings.
LASTRUNWARN=$(grep -e "^ *level:" ${LASTRUNREPORT} | grep -e "warning" | wc -l)
if [ ${LASTRUNWARN} -gt 0 ] ; then
  echo "Agent warning: Last run had ${LASTRUNWARN} warning(s)."
  exit ${STATE_WARNING}
fi

# If there's no errors or warnings, everything must be okay, right?
echo "Agent OK: Puppet agent ${PRUN_version_puppet} last ran at $(date -d @${PRUN_time_last_run} +%c) for ${PRUN_time_total} secs. | resources_total=${PRUN_resources_total}, resources_out_of_sync=${PRUN_resources_out_of_sync}, time_total=${PRUN_time_total}"
exit ${STATE_OK}
