#!/bin/bash

# NAME: testver
# PATH: /usr/local/bin
# DESC: Test a program's version number >= to passed version number
# DATE: May 21, 2017. Modified August 5, 2019.

# CALL: testver Program Version

# PARM: 1. Program - validated to be a command
#       2. Version - validated to be numberic
#       3. eg. command- versionChecker.sh cmake 3.2; echo $?
# NOTE: Extracting version number perl one-liner found here:
#       http://stackoverflow.com/questions/16817646/extract-version-number-from-a-string

#       Comparing two version numbers code found here:
#       http://stackoverflow.com/questions/4023830/how-compare-two-strings-in-dot-separated-version-format-in-bash

# Map parameters to coder-friendly names.
Program="$1"
Version="$2"

# Program name must be a valid command.
command -v $Program >/dev/null 2>&1 || { echo "Command: $Program not found. Check spelling."; exit 99; }

# Passed version number must be valid format.
if ! [[ $Version =~ ^([0-9]+\.?)+$ ]]; then
    echo "Version number: $Version has invalid format. Aborting.";
    exit 99
fi

InstalledVersion=$( "$Program" --version | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/' )

# Perl command doesn't work for non-decimal version numbers
[[ "$InstalledVersion" == "" ]] && 
     InstalledVersion=$( "$Program" --version | head -n1 | tr -dc '0-9')

if [[ $InstalledVersion =~ ^([0-9]+\.?)+$ ]]; then
    l=(${InstalledVersion//./ })
    r=(${Version//./ })
    s=${#l[@]}
    [[ ${#r[@]} -gt ${#l[@]} ]] && s=${#r[@]}

    for i in $(seq 0 $((s - 1))); do
        # echo "Installed ${l[$i]} -gt Test ${r[$i]}?"
        [[ ${l[$i]} -gt ${r[$i]} ]] && exit 0 # Installed version > test version.
        [[ ${l[$i]} -lt ${r[$i]} ]] && exit 1 # Installed version < test version.
    done

    exit 0 # Installed version = test version.
else
    echo "Invalid version number: $InstalledVersion found for command: $Program"
    exit 99
fi

echo "testver - Unreachable code has been reached!"
exit 255
