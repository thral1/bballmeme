#! /bin/sh

# Shell script to check if task_scheduler is still running and restart it if necessary

SERVICE='task_scheduler.rb'

#GEM_PATH='/home/deviagaz/ruby/gems:/usr/lib64/ruby/gems/1.8'

export PATH=$PATH:/home7/deviagaz/ruby/gems/bin
export GEM_HOME=/home7/deviagaz/ruby/gems

if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
   echo "$SERVICE is running, everything is fine"
else
   echo "$SERVICE is not running!" 1>&2
   cd ~/bballmeme
   ./$SERVICE > tmp/jcen.log 2>&1 &
   SEARCH=$(ps ax | grep -v grep | grep $SERVICE)
   echo "but it should be running now" 1>&2
   echo "$SEARCH" 1>&2
fi