#!/bin/bash

NOAA_STATION=KSTL
SERVICE_URL="https://api.weather.gov/stations/${NOAA_STATION}/observations/latest"

TEMP_C=$(/usr/bin/curl -s ${SERVICE_URL} \
    | /usr/bin/jq '.properties.temperature.value' \
    )

TEMP_F=$(echo "1.8 * ${TEMP_C} + 32" | /usr/bin/bc)

echo "$TEMP_F °F"
