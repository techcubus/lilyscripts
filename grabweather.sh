#!/bin/bash

SITE=LSX
PRODUCT=ZFP
ZONE=MOZ063-064-232115


/bin/curl -s "http://forecast.weather.gov/product.php?site=${SITE}&issuedby=LSX&product=${PRODUCT}&format=TXT&version=1&glossary=0" | /bin/sed -n '/MOZ063-064-282115/,/$$/p'