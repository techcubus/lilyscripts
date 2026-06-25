#!/bin/bash

printf "%-12s %s\n" "Device" "Device Model"
printf "%-12s %s\n" "------" "------------"

for dev in /dev/sd?; do
    model=$(smartctl -x "$dev" 2>/dev/null | awk -F': ' '/^Device Model/ { gsub(/^[[:space:]]+/, "", $2); print $2; exit }')
    printf "%-12s %s\n" "$dev" "${model:-(not available)}"
done
