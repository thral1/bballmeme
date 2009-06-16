#! /bin/sh


# Date will be based on Year and Week number
TODAY=`/bin/date +%Y_%V`

# Define what to archive here
#  Archive articles older than 42 days based on pub date
WHERE_CLAUSE=

# declare some constants
HOST=localhost
USER=deviagaz_rails
PASS=password

SCHEMA=deviagaz_bballmeme
TABLE=articles

ARCHIVE_SCHEMA=deviagaz_bmArchive
ARCHIVE_TABLE=articles_$TODAY
PERL_EXT_MOD=Archiver

#DEBUG=--no-delete

export PERL5LIB=/home/deviagaz/bballmeme/perl

/home/deviagaz/bin/mk-archiver --source h=$HOST,u=$USER,p=$PASS,t=$TABLE,D=$SCHEMA --where 'publication_date < (now() - interval 1 week)' --dest D=$ARCHIVE_SCHEMA,t=$ARCHIVE_TABLE,m=$PERL_EXT_MOD $DEBUG

echo "Done!"
