#! /usr/bin/env bash

# USAGE: 
#   # Dry run (-n):
#   ./deprecatePreviousAlphas.sh -n @platter/<package-you-own> "Deprecation text"
#   # For real:
#   ./deprecatePreviousAlphas.sh @platter/<package-you-own> "Deprecation text"


# Get args
# (what even is bash)
MAYBE_ECHO_NPM="npm"
while getopts "n" flag;
do
  case "$flag" in
    n) MAYBE_ECHO_NPM="echo WOULD HAVE RUN npm";;
  esac
done
PACKAGE=${@:$OPTIND:1}
MESSAGE=${@:$OPTIND+1:1}

# Exit early if package does not exist
npm info "$PACKAGE" &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "$PACKAGE" does not exist on npm
  exit 1
fi

# Deprecate all but most recent package (sed '$d' removes last line of input)
npm view "$PACKAGE" versions --json \
  | grep -v -e '\[' -e ']' \
  | sed 's/[", ]//g' \
  | sed '$d' \
  | xargs -I {} $MAYBE_ECHO_NPM deprecate "$PACKAGE@"{} "$MESSAGE"

