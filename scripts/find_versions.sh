#!/bin/bash

# Make the "." not a wildcard and be the value "." to search.
FIRST_ARG="${1//./\\\.}"
ALL_MCVERSIONS=$(tail -n +2 available_versions.csv | awk -F'|' '{print $1}' | tac)

if [[ "$FIRST_ARG" == "" ]]; then
	echo -e "$ALL_MCVERSIONS"
	exit 0
fi

if echo -e "$ALL_MCVERSIONS" | grep "$FIRST_ARG" -q; then
	echo "Current Results:"
	echo -e "$ALL_MCVERSIONS" | grep "$FIRST_ARG"
else
	echo "There are no results."
fi
