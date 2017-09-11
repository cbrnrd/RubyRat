#!/bin/bash
if [ $1 == '--help' ]; then
  echo "Usage: build_client.sh <osx,win,lin> <EXENAME>"
  exit 0
fi

PLAT=$1
EXENAME=$2

# TODO do env checking

rb2exe rubyrat_client.rb --target=$PLAT -o $EXENAME --add=.
