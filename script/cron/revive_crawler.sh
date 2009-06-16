#! /bin/sh

# Shell script to check if crawler is still running and restart it if necessary

SERVICE='crawler.pl basketball'
SERVICE2='crawler.pl football'


if ps ax | grep -v grep | grep "$SERVICE" > /dev/null
then
   echo "$SERVICE is running, everything is fine"
else
   echo "$SERVICE is not running!" 1>&2
   cd ~/bballmeme/perl
   ./$SERVICE >> ../log/crawler_basketball.log 2>&1 &
   SEARCH=$(ps ax | grep -v grep | grep "$SERVICE")
   echo "but it should be running now" 1>&2
   echo "$SEARCH" 1>&2
fi

if ps ax | grep -v grep | grep "$SERVICE2" > /dev/null
then
   echo "$SERVICE2 is running, everything is fine"
else
   echo "$SERVICE2 is not running!" 1>&2
   cd ~/bballmeme/perl
   ./$SERVICE2 >> ../log/crawler_football.log 2>&1 &
   SEARCH=$(ps ax | grep -v grep | grep "$SERVICE2")
   echo "but it should be running now" 1>&2
   echo "$SEARCH" 1>&2
fi
