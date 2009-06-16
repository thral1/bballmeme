#! /usr/bin/perl
# Jia Fu Cen
# Top level file for the RSS crawler


# fix parsing of XML and RDF into the RSS object
#
#
#
#
#
#
#
#
#


use lib "/home/deviagaz/perl_includes/lib/perl5/site_perl/5.8.8/";
#use lib "/home/deviagaz/perl_includes/lib/perl5/site_perl/5.8.8/x86_64-linux/";
use lib "/home/deviagaz/bballmeme/perl/WWW-Mechanize-1.60/lib/";
use lib "/home/deviagaz/perl_includes/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi/";

use strict;
#use warnings;
#use LWP::Simple;
use Date::Parse;
use Data::Dumper;
#use Unicode::String qw(latin1 utf8);
#use Unicode::Normalize;
#use Encode;
#use utf8;
use XML::FeedPP;
use HTML::Parser;
use WWW::Mechanize;
use Text::Unidecode;
use POSIX qw(strftime);
use DBI;
#binmode STDOUT, ":utf8";
  
my $sport = "";
my $article_type = "";
my $subscription_file = "perl\/rss_subs.txt";
my $NEW_ARTICLES_FILE = "perl\/new_articles2.txt";
my $RSS_DISCOVER_INTERVAL = 120; # in seconds
my $RSS_AGGREGATE_INTERVAL = 600; # in seconds

#my $DBI_SOURCE = "DBI:mysql:database=deviagaz_bballmeme;host=localhost";
my $DBI_SOURCE = "dbi:mysql:deviagaz_bballmeme:localhost:3306";
#my $DBI_SOURCE = "dbi:SQLite:/home/deviagaz/bballmeme/db/production.sqlite3";
my $DBI_USER   = "deviagaz_rails";
#my $DBI_USER   = "";
my $DBI_PASSWD = "password";
#my $DBI_PASSWD = "";
my $dbh = undef;

my $USE_STORED_FILE = 1;
my $DUMP_FIRST_RUN = 1;

my $debug_new = 0;

my $instance_id = time;

# Add list of possible proxy sites that might cause redirects here (e.g. google)
my @REDIRECT_SUSPECTS = qw/
  feedproxy.google
  www.pheedcontent.com
  us.rd.yahoo.com
  feeds.cbssports.com
  feeds.feedburner.com
  www.philly.com
/;

# Add list of possible fake articles (e.g. adverts)
my @SPAM_SUSPECTS = qw/
  ads.pheedo.com
  ad.doubleclick.net
/;

# Add list of unnecessary url elements that can lead to "duplicate" urls
my @UNNCESSARY_URL_ELEMENTS = qw/
  \s*()
  (\.html)\?.*
  (\.html)\#.*
  \&?ref=.*(\&|\b)
  \&?cxntfid=.*(\&|\b)
  \&?utm_source=.*(\&|\b)
  \&?utm_medium=.*(\&|\b)
  \&?utm_campaign=.*(\&|\b)
  \&?source=.*(\&|\b)
  \&?campaign=.*(\&|\b)
  \&?template=.*(\&|\b)
  \&?ncid=.*(\&|\b)
  \&?xid=.*(\&|\b)
  \&?cxtype=.*(\&|\b)
  \&?related=.*(\&|\b)
  \&?located=.*(\&|\b)
  \/1058(\b)
  \/1057\/PKR(\b)
  \/sports03(\b)
  ()\/rss$
  ()\&+$
  ()\?+$
  ()\/+$
/;
# examples:
# http://www.greenbaypressgazette.com/article/20091231/PKR01/91231108/1058
# http://www.greenbaypressgazette.com/article/20091231/PKR01/91231108/1057/PKR
# http://www.indystar.com/article/20100106/SPORTS03/100106008/1100/sports03

# can't account for dupes like these:
#'http://blogs.chron.com/fanblogtexans/2010/01/how_bout_them_texans_1.html'
#'http://blogs.chron.com/fanblogtexans/2010/01/how_bout_them_texans.html'


# List of unncessary title elements like (AP)
my @UNNECESSARY_TITLE_ELEMENTS = (
  qr/ \(AP\)/,
  qr/ \(The Canadian Press\)$/,
  qr/ - ESPN$/,
  qr/ \(Yahoo\! Sports\)$/,
  qr/ \(blog\)$/,
  qr/ \(PA SportsTicker\)$/,
  qr/ - Daily Mail$/,
  qr/ - Plain Dealer$/,
  qr/ - Orlando Sentinel$/,
  qr/ - SportingNews\.com$/,
  qr/ - New York Times$/,
  qr/ - Bodog Beat$/,
  qr/ - FOXNews$/,
  qr/ - OrlandoMagic\.com$/,
);

# list of regexp for detecting game recaps
my @GAME_RECAP_REGEXP = (
  qr/(?<!\()\d{2,3} ?- ?\d{2,3}(?!\))/,
  qr/[A-Z7]\w+\s?((?i)(beats|beat|upset|over|clobber|stop|end|past|knock off|rout|edge|fall to|upend|ground|\'s? dominance over|run past|stun|take down|\'s? rout of|\'s? win overdown|get by|bounce|rip|get victory over|hold off)) [A-Z7]\w+/,
  qr/[A-Z7]\w+,? \d{2,3},? .+ \d{2,3}/,
  qr/(?i)Game \w* ?Recap/,
  qr/(?i)\w+-\w+, Box/,
  qr/^Recap: /,
  qr/recap\)$/,
  qr/win .*straight|cruise past overmatched|escape with (a )?win over|run streak against|stop road losing skid with win over|(snap|end) .+game win(ning)? streak|coasting to win|(hand|deal) .+ straight loss|snap road losing streak/i,
  qr/win streak snapped by|no match for|latest bid foiled by|nother step/i,
);



#-------------- Main routine ------------------------------
#pipe(FHX, FHY);
if (@ARGV > 0) {
  $subscription_file = $ARGV[2];
  $NEW_ARTICLES_FILE = $ARGV[1];
  $sport = $ARGV[0];
  if( $sport =~ /basketball/i )
  {
    $article_type = "BBArticle";
    print "BBArticle";
  }
  elsif( $sport =~ /football/i )
  {
    $article_type = "FBArticle";
    print "FBArticle";
  }
  
  print "Dumping new articles to $NEW_ARTICLES_FILE\n";
  main();
}
else {
  print "Must specify 'basketball' or 'football'\n";
  exit 0;
}


#-------------- Sub routines ------------------------------

# sub main
# 
sub main {
   my @subs = ();
   my %aggregators;
   my %aggregators_teams;
   my %aggregators_types;
   my %aggregators_feed_scores;

   # seed the aggregators
   #read_sub_file(\@subs);
   get_feeds_from_db(\@subs);

   foreach my $sub (@subs) {
     
     my ($rss_url, $teams, $type, $feed_scores) = split( /,/, $sub );

      #print "==== $rss_url is about these teams: $teams ====\n";
      #print "==== $rss_url is about these types: $type ====\n";
      
      my $xml;
      my $page;
      my $rss;
      my $filename = cleanup($rss_url);
     
      if (-e "rdf\/$filename.rdf" && $USE_STORED_FILE) {
      
        eval { $rss = XML::FeedPP->new("rdf\/$filename.rdf" , -type => 'file'); };
        if ($@) { 
          print "Can't open rdf\/$filename.rdf ($@)\n"; 
          next; 
        }
 
      } else {
 
        eval { $rss = XML::FeedPP->new( $rss_url ); };
        if ($@) { 
          print "Can't fetch $rss_url ($@)\n";
          if ($@ =~ /Invalid tag sequence/i) {
            # probably not a feed. may be a regular html page
            print STDERR "$rss_url may not be a feed\n";
          }
          next; 
        }
        eval { $rss->to_file("rdf\/$filename.rdf", 'ascii') }; 
        warn "$@" if $@;

        # read it back
        eval { $rss = XML::FeedPP->new("rdf\/$filename.rdf" , -type => 'file'); };
        warn "$@" if $@;
        
        if ($DUMP_FIRST_RUN) {
          my @a = $rss->get_item();
	  my $title = $rss->title();
          queue_items($title, $rss_url, $teams, $type, $feed_scores, \@a);
        }
      }
     
      $aggregators{$rss_url} = $rss;
      $aggregators_teams{$rss_url} = $teams;
      $aggregators_types{$rss_url} = $type;
      $aggregators_feed_scores{$rss_url} = $feed_scores;

      undef $rss;
      
   }
   
   # fork process to update readers and update the aggregators
   #my $pid = fork();
   #if ($pid == 0)
      #print "This is the RSS crawl process\n";
      #rss_discover(\%aggregators);
   #   exit 0;
   #}
   #print "This is the aggregate process and child ID is $pid\n";
   sleep(1);
   while (1) {
     rss_aggregate(\%aggregators, \%aggregators_teams, \%aggregators_types, \%aggregators_feed_scores);
   }
   exit 0;
}

# sub read_sub_file
#  takes reference to array and populates it with RSS URLs
# 
sub read_sub_file {
   my ($arr_ref) = @_;
   my $i = 0;

   print "sub_file is $subscription_file\n";
   open (SUB_FILE, "< $subscription_file");
   while (<SUB_FILE>) {
      chomp;
      if (/^http/) {
         push (@$arr_ref, $_);
         $i++;
      }
   }
   close SUB_FILE;

   print "Found $i subscriptions in $subscription_file\n";
}

# sub get_feeds_from_db
#   takes reference to array and populates ith with RSS URLs
sub get_feeds_from_db {
   my ($arr_ref) = @_;
   my $i = 0;

   $dbh ||= DBI->connect(
                           $DBI_SOURCE,
                           $DBI_USER,
                           $DBI_PASSWD,
                           { AutoCommit => 1,
                             RaiseError => 1, },
                          );
   $dbh->{mysql_auto_reconnect} = 1;

   my $query = "SELECT DISTINCT url, team, feed_type, relevance from feeds WHERE ( (active is null or active <> 0) and (sport like \"%" . $sport . "%\") )";

   eval {
      my $sth = $dbh->prepare($query);
      $sth->execute();

      my $result = $sth->fetchall_arrayref();

      # copy to data over
      @{$arr_ref} = map { qq($_->[0],$_->[1], $_->[2], $_->[3]) } @{$result};

      print Dumper ($arr_ref);
   };

   #$dbh->disconnect();
}

# sub rss_discover
#  look for more RSS feeds out there and append to list
#
sub rss_discover {
   my ($hash_ref) = @_;

   local $| = 1;
   while (1) {
      print "<<< Looking for RSS feeds out there...\n";


      sleep $RSS_DISCOVER_INTERVAL;
      
   }
}

# sub rss_aggregate
#   periodically update the existing RSS feeds 
#
sub rss_aggregate {
   my ($hash_ref, $teams_ref, $type_ref, $feed_scores_ref) = @_;
   my @stories = ();

   do {
      foreach (keys %$hash_ref) {
         my $rss_url = $_;
         my $teams_associated_with_this_feed = $teams_ref->{$rss_url} || '';
         my $type = $type_ref->{$rss_url} || '';
         my $feed_score = $feed_scores_ref->{$rss_url} || '';
         my $filename = cleanup($rss_url);

         if (needs_refresh("rdf\/$filename")) {
            
            my $feed = $_;
            my $rss = $$hash_ref{$feed};
   
            print "\n>>> Checking for more articles from $feed\n";
            my $fresh_rss;
            eval { $fresh_rss = XML::FeedPP->new($feed); };
            if ($@) {
              print "error aggregating ($@)\n";
              next;
            }
            # save to a file
            $fresh_rss->to_file("rdf\/$filename.rdf", 'ascii');
            # read it back to get all ascii format
            eval { $fresh_rss = XML::FeedPP->new("rdf\/$filename.rdf" , -type => 'file'); };
            warn "rdf error: $@\n" if $@;
            # keep a reference to use later
            $$hash_ref{$feed} = $fresh_rss;

            #$fresh_rss->aggregate( sources => [ $feed ] );
            #$rss->aggregate( sources => [ $_ ] );
            # how do we know if we got new articles?
            
            my @new_items;
            {
              my @a = $fresh_rss->get_item();
              my @b = $rss->get_item();
              @new_items = array_diff(\@a, \@b);
            }

            my $num_new_items = scalar(@new_items);

            if ($num_new_items && $debug_new) {
              my @a = $fresh_rss->get_item();
              my @b = $rss->get_item();
              debug_new(\@a, \@b, \@new_items);
            }

            print "Got $num_new_items new articles\n";
	    my $title = $rss->title();

            queue_items($title, $rss_url, $teams_associated_with_this_feed, $type, $feed_score, \@new_items);
 
         }
      }

      sleep $RSS_AGGREGATE_INTERVAL;
   } while (0);
   
}

# sub cleanup
#  take a URL and clean up the semicolons and slashes so we can make a filename out of it
#
sub cleanup {
   my ($f) = @_;

   $f =~ s/:\/\//_/;
   $f =~ s/\//_/g;
   $f =~ s/\./_/g;
   $f =~ s/\?/_/g;
   $f =~ s/;/_/g;
   $f =~ s/&//g;
   $f =~ s/%//g;
   $f =~ s/=//g;

   return $f;

}

sub needs_refresh {
   my ($filename) = @_;

   if (! -e "$filename.rdf") {
      print "$filename doesn't exist\n";
      return 1;
   }

   my $mod = (stat("$filename.rdf"))[9];
   $mod -= time(); $mod *= -1;
   print "elapsed seconds since last modification: $mod\n";

   if ($mod > $RSS_AGGREGATE_INTERVAL) {
      return 1;
   } else {
      return 0;
   }
}


# Diff two arrays of hashes and return the difference
sub array_diff {
   my ($ref_a, $ref_b) = @_;

   my %check = ();
   my @diff = ();
   
   map { $check{strip($_->title())} = 1 } @{$ref_b};

   map { push (@diff, $_) unless ($check{strip($_->title())}) } @{$ref_a};

   return @diff;
}

sub xml_clean {

   my ($s) = @_;

   $s =~ s/&nbsp;/ /g;
   $s =~ s/&rdquo;/\"/g;
   #$s =~ s/&/&amp;/g;
   $s =~ s/&lt;/</g;
   $s =~ s/&gt;/>/g;
   $s =~ s/&amp;/&/g;

   return $s;
}

sub strip {
   my ($s) = @_;

   $s =~ s/\s+$//;
   $s =~ s/^\s+//;

   return $s;
}

sub print_to_log {
  my ($feed, $title, $link, $desc, $date, $author, $feed_name, $teams_associated_with_this_url) = @_;
  
  $title =~ s/^\s+//g;
  $desc =~ s/^\s+//g;
  
  open (LOG, ">> $NEW_ARTICLES_FILE") or die "Can't open $NEW_ARTICLES_FILE ($!)";
  
  my $desc_text = '';
  my $p = HTML::Parser->new(text_h => [sub { $desc_text .= shift }, 'text'],
                             comment_h => [""],
                             );
  $p->parse($desc);
  
  $desc = $desc_text;
  #print " -------- $desc\n";
  $desc =~ s,\\\',,g; #get rid of the slash apostrophes
  #print ">>>$desc\n";
  
  
  my %ascii = ( feed  => $feed, 
                 title => $title, 
                 link  => $link, 
                 desc  => $desc,
                 date  => $date,
                 author=> $author,
                 feed_name => $feed_name,
                 teams_associated_with_this_url => $teams_associated_with_this_url,
                 feed_level => 1,   #TBD, hard code for now
  );
  my $dump = Dumper(%ascii);
  $dump =~ s,\\\',\',g; # Dumper escapes the apostrophe, we need to unescape it

  print LOG "$dump\n";
  close LOG;

  
}

my %need_to_insert = ();
my $push_db_counter = 0;
my $exp_backoff_cap = 5; # after x tries, stop using exponential backoff

sub push_to_db {
  my ($feed, $title, $link, $desc, $date, 
      $author, $feed_name, $teams_associated_with_this_url, $type, $feed_score, $localtime) = @_;

  # queue up this article for insert into database
  my @data = @_;
  $need_to_insert{$link} = { attempt => 1, next_attempt => $push_db_counter, data => \@data };

  # now process all insertions that are due
  foreach my $url (keys %need_to_insert) {
     next unless $url;
     if ($need_to_insert{$url}->{next_attempt} <= $push_db_counter) {
     
        my $status = push_to_db_int(@{$need_to_insert{$url}->{data}});
        my $this_attempt = $need_to_insert{$url}->{attempt};

        if ($status == 1) {
           # insert succeeded so remove from list of articles to push
           print sprintf ("on attempt %d, %s... pushed to database!\n", $this_attempt, substr($url,0,40));
           delete $need_to_insert{$url};
        } else {
           # insert failed so need to reschedule for later; use exponential backoff so we don't end up pounding the server
           $need_to_insert{$url}->{attempt} = $this_attempt + 1;
           my $next_attempt = ($this_attempt >= $exp_backoff_cap) ? 1 << $exp_backoff_cap : 1 << $this_attempt;  # cap retry at 32 iterations later
           $need_to_insert{$url}->{next_attempt} = $push_db_counter + $next_attempt;
           print sprintf ("on attempt %d/%d, %s... failed insert!\n", $this_attempt, $next_attempt, substr($url,0,50));
        }
     }
  }

  # increment counter
  $push_db_counter++;
}

sub push_to_db_int {
  my ($feed, $title, $link, $desc, $date, 
      $author, $feed_name, $teams_associated_with_this_url, $type, $feed_score, $localtime) = @_;
  
  $title =~ s/^\s+//g;
  $desc =~ s/^\s+//g;
    
  my $desc_text = '';
  my $p = HTML::Parser->new(text_h => [sub { $desc_text .= shift }, 'text'],
                             comment_h => [""],
                             );
  $p->parse($desc);
  
  $desc = $desc_text;
  $desc =~ s,\\\',,g; #get rid of the slash apostrophes
  $desc = substr($desc,0,2000);  # don't take the whole article now
  
  my %attrib = ( publication_name            => $feed, 
                 title                       => $title, 
                 url                         => $link, 
                 rss_description             => $desc,
                 publication_date            => $date,
                 author                      => $author,
                 publication_name            => $feed_name,
                 teams_associated_with_url   => $teams_associated_with_this_url,
                 article_type                => $type,
                 feed_score                  => $feed_score,
                 rss_feed_level              => 1,   #TBD, hard code for now
                 article_rank                => 0,
                 score                       => 0,  
                 num_visitors_per_month      => 0, 
                 num_backward_links          => 0,
                 num_comments                => 0,
                 created_at                  => $localtime,
                 type                        => $article_type,
  );

  $dbh ||= DBI->connect(
                          $DBI_SOURCE,
                          $DBI_USER,
                          $DBI_PASSWD,
                          { AutoCommit => 1,
                            RaiseError => 1, },
                         );
  $dbh->{'mysql_auto_reconnect'} = 1;

  #jlk - in the future, with multiple articles with the same title, keep the one that would have the highest score.
  # Need to figure out how to do that.  For now just accept the first, reject the rest
   my $esc_title = $title;
   $esc_title =~ s/'/\\'/g;
  my $query = "SELECT url from articles where (url = '$link' or title = '$esc_title')";
  #print $query . "\n";

  eval {
     no warnings;

     my $sth = $dbh->prepare($query);
     $sth->execute();

     my $result = $sth->fetchall_arrayref();
     $sth->finish();
     
#     my $result = [];

     if (scalar @{$result}) {
        print "$link already exists in the database!\n";
     } else {
        my $cols = join (',', keys (%attrib));
        my $vals = join (',', map { $dbh->quote($_) } values(%attrib));
        $query = "INSERT INTO articles ($cols) VALUES ($vals)";
        #print "insert query = $query\n";

        my $sth2 = $dbh->prepare($query) or do { die $dbh->errstr; };
        $sth2->execute() or do { die $dbh->errstr; };


        # debug funky chars
        print "debug: url = ".$attrib{url}."\n";
        print "debug: rss_des = ".$attrib{rss_description}."\n";
     }
  };
  if ($@ =~ /execute failed: Duplicate entry/) {
     #chomp $@;
     #warn "Push to db failed: $@\n";
     print "$link already exists in the database!\n";
     return 1;
  } elsif ($@) {
     return 0;
  }
  return 1;
}


sub queue_items {
   my ($title, $rss_url, $teams_associated_with_this_url, $type, $feed_score, $ref_arr) = @_;

   my $mech = WWW::Mechanize->new();

OUTER:
   foreach (@$ref_arr) {
     my $headline = $_->title();
     my $keywords = '';
     $headline =~ s/^\s+//g;
     $headline =~ s/\s+$//g;
     chomp($headline);
     
      #jcen print "  " . $headline . "\n";

      #=========================================
      # Do processing of the article here
      #==========================================
      my $feed_link = $_->link();
      my $resolved_link = $feed_link;

      # weed out the spam links
      foreach (@SPAM_SUSPECTS) {
         next OUTER if ($feed_link =~ /\Q$_\E/);
      }

      # resolve links to final url for some sites (e.g. feedburner)
      foreach (@REDIRECT_SUSPECTS) {
         eval {
            if ($feed_link =~ /\Q$_\E/) {
               my $resp = $mech->get($feed_link);   
	       my $status = $mech->status();
	       $resolved_link = $mech->uri()->as_string();
               if ($feed_link ne $resolved_link) {
                  #jcen print "  ^REDIRECTED link!\n";
	          last;
               }
            }
         };
      }

      # clean up the url to get rid of unncessary elements in the url
      #  (this is probably more appropriate in the evaluator but do it here for now
      foreach (@UNNCESSARY_URL_ELEMENTS) {
         $resolved_link =~ s/$_/$1/ig;  # assume that the regexp captures backward references (i.e. $1)
      }

      # get rid of the extraneous title elements (e.g. (AP))
      foreach my $re (@UNNECESSARY_TITLE_ELEMENTS) {
	 $headline =~ s/$re/$1/;
         #print "using $re\n";
      }

      # check to see if this article might be a recap
      if ($resolved_link =~ /recap/i) {
	 $keywords = ' recap';
      } else {
         foreach my $re (@GAME_RECAP_REGEXP) {
            if ($headline =~ m/$re/x) {
               $keywords = ' recap';
               print "Recap: matched $& \n";
               last;  # only need to know if it matches one
            }
         }
      }

      # get the current time in a nice format
      my $dt = str2time($_->pubDate());
      # make sure the pub time is not later than now (can't be published in the future)

      $dt = ($dt > time) ? time : $dt;

      my $datetime = strftime("%Y-%m-%d %H:%M:%S", localtime($dt));
      my $localtime = strftime("%Y-%m-%d %H:%M:%S", localtime);

      # put into the queue implementation
      #  at the moment, our queue is a database table with a created_at timestamp
      push_to_db ( $title || '',
                    $headline || '',
                    $resolved_link || '',
                    $_->description() || '',
                    $datetime || '',
                    $_->author() || '',
                    $rss_url || '',
                    $teams_associated_with_this_url || '',
                    $type.$keywords || '',
                    $feed_score || '',
                    $localtime
                  );  
   }
   
}

sub debug_new {
   my ($refa, $refb, $refdiff) = @_;

   my $i = 1;
   foreach (@$refdiff) {
      print "D$i $_->title()+++\n";
      $i++;
   }

   $i = 1;
   foreach (@$refa) {
      print "A$i $_->title()+++\n";
      $i++;
   }

   $i = 1;
   foreach (@$refb) {
      print "B$i $_->title()+++\n";
      $i++;
   }


}


1;
__END__




   #my $rss = XML::RSS::Aggregate->new(
        # parameters for XML::RSS->channel()
        #title   => 'Hoops A Lot',
        #link    => 'http://www.example.com/rdf',

        # parameters for XML::RSS::Aggregate->aggregate()
        #sources => \@subs,

        #sort_by => sub {
        #    $_[0]->{dc}{subject}    # default to sort by dc:date
        #},

        #uniq_by => sub {
        #    $_[0]->{title}          # default to uniq by link
        #}
   #);

   #$rss->aggregate( sources => \@subs );  # more items
   #$rss->save("all.rdf");

   #foreach my $item (@{$rss->{'items'}}) {
   #   print "title: $item->{'title'}\n";
   #   print "link: $item->{'link'}\n\n";
   #}
