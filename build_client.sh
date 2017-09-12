#!/bin/bash
if [ $1 == '--help' ]; then
  echo "Usage: build_client.sh <osx,win,l32,l64> <EXENAME>"
  exit 0
fi

PLAT=$1
EXENAME=$2

# TODO env checking

rb2exe rubyrat_client.rb --target=$PLAT -o $EXENAME --add=.
