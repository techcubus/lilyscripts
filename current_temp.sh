#!/bin/bash

/usr/bin/curl -s "http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=KSTL" \
    | /usr/bin/grep temperature_string \
    | /usr/bin/sed -e 's/.*<temperature_string>\(.*\)<\/temperature_string>/\1/'
