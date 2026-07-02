#!/bin/bash
  
while IFS= read -r repo; do
  dir="${repo#*/}"  # strip "owner/" prefix → just the repo name
  if [ ! -d "$dir" ]; then
    git clone "git@github.com:${repo}.git"
  fi
done < <(gh repo list --limit 1000 | awk '{ print $1 }')

