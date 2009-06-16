#! perl
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
use lib "/home/deviagaz/perl_includes/lib/perl5/site_perl/5.8.8/x86_64-linux/";
use strict;
use LWP::Simple;
use Data::Dumper;
use Unicode::String qw(latin1 utf8);
use Unicode::Normalize;
use Encode;
use utf8;
use Data::Dumper;
use XML::FeedPP;
use HTML::Parser;
binmode STDOUT, ":utf8";
  
my $subscription_file = "perl//rss_subs.txt";
my $NEW_ARTICLES_FILE = "perl//new_articles2.txt";
my $RSS_DISCOVER_INTERVAL = 120; # in seconds
my $RSS_AGGREGATE_INTERVAL = 600; # in seconds


my $USE_STORED_FILE = 1;
my $DUMP_FIRST_RUN = 1;

my $debug_new = 0;

my $instance_id = time;

#-------------- Main routine ------------------------------
#pipe(FHX, FHY);
if (@ARGV > 1) {
  $subscription_file = $ARGV[0];
  $NEW_ARTICLES_FILE = $ARGV[1];
  print "Dumping new articles to $NEW_ARTICLES_FILE\n";
}
main();


#-------------- Sub routines ------------------------------

# sub main
# 
sub main {
   my @subs = ();
   my %aggregators;

   # seed the aggregators
   read_sub_file(\@subs);

   foreach (@subs) {
     
     my $rss_url = $_;

      print "==== $rss_url ====\n";
      
      my $xml;
      my $page;
      my $rss;
      my $filename = cleanup($rss_url);
     
      if (-e "rdf\\$filename.rdf" && $USE_STORED_FILE) {
      
        eval { $rss = XML::FeedPP->new("rdf\\$filename.rdf" , -type => 'file'); };
        if ($@) { 
          print "Can't open rdf\\$filename.rdf ($@)\n"; 
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
        eval { $rss->to_file("rdf\\$filename.rdf") }; 
        warn "$@" if $@;
        
        if ($DUMP_FIRST_RUN) {
          my @a = $rss->get_item();
          queue_items($rss->title(), $rss_url, \@a);
        }

      }
     
      $aggregators{$rss_url} = $rss;
      
   }
   
   # fork process to update readers and update the aggregators
   my $pid = fork();
   if ($pid == 0){
      #print "This is the RSS crawl process\n";
      #rss_discover(\%aggregators);
      exit 0;
   }
   #print "This is the aggregate process and child ID is $pid\n";
   sleep(1);
   while (1) {
     rss_aggregate(\%aggregators);
   }
   exit 0;
}

# sub read_sub_file
#  takes reference to array and populates it with RSS URLs
# 
sub read_sub_file {
   my ($arr_ref) = @_;
   my $i = 0;

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
   my ($hash_ref) = @_;
   my @stories = ();

   do {
      foreach (keys %$hash_ref) {
         my $rss_url = $_;
         my $filename = cleanup($rss_url);

         if (needs_refresh("rdf\\$filename")) {
            
            my $feed = $_;
            my $rss = $$hash_ref{$feed};
   
            print "\n>>> Checking for more articles from $feed\n";
            my $fresh_rss;
            eval { $fresh_rss = XML::FeedPP->new($feed); };
            if ($@) {
              print "error aggregating ($@)\n";
              next;
            }

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

            queue_items($rss->title(), $rss_url, \@new_items);
            #foreach (@new_items) {
            #   print "  " . $_->{'title'} . "\n";
            #   
            #   my $date = $_->{'dc'}->{'date'} || $_->{'pubDate'};
            #   send_email_2( $rss->channel->{'title'}, $_->{'title'}, $_->{'link'}, $_->{'description'}, $date );
            #}

            #foreach (@{$rss->{'items'}}) {
            #   print "fake items\n";
            #   print "  " . $_->{'title'} . "\n";
            #   my $date = $_->{'dc'}->{'date'} || $_->{'pubDate'};
            #   send_email_2( $rss->channel->{'title'}, $_->{'title'}, $_->{'link'}, $_->{'description'}, $date );
            #}

            if ($num_new_items > 0) {
               $$hash_ref{$feed} = $fresh_rss;

               $fresh_rss->to_file("rdf\\$filename.rdf");
            } else {
               #print "No new articles\n"
            }

            #foreach (@{$fresh_rss->{'items'}}) {
            #   print "Fresh: ". $_->{'title'} . "\n";
            #}
   
            #for my $item (@{$rss->{'items'}}) {
            #   print "Old: " . $item->{'title'} . "\n";
            #   push @stories, {
            #      FEED_NAME  => $rss->channel->{'title'},
            #      FEED_URL   => $rss->channel->{'link'},
            #   
            #      STORY_NAME => $item->{'title'},
            #      STORY_URL  => $item->{'link'},
            #      STORY_DESC => $item->{'description'},
            #      STORY_DATE => $item->{'dc'}->{'date'} || $item->{'pubDate'},
            #    
            #   }
            #}
 
         }
      }

      foreach (@stories) {
         #print Dumper($_); 
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
   my @diff;
   
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

sub send_email {
   my ($title, $link) = @_;

   my $server = 'smtphost.qualcomm.com';
   my $recip = 'jcen@qualcomm.com';
   my $subject = 'Testing crawler';

   my %mailSetup;

   $mailSetup{Subject} = $subject;
   $mailSetup{Message} = "$title\n$link";
   #$mailSetup{Type} = 'multipart/mixed';
   $mailSetup{From} = 'jcen@qualcomm.com';
   $mailSetup{To}   = $recip;

   my $msg = MIME::Lite->new(%mailSetup);

   if ($msg->send('smtp', $server)) {
      print "Email was sent successfully\n";
   }
   else {
      print "Error occured while sending mail\n";
   }
}

sub send_email_2 {

   my ($feed, $title, $link, $desc, $date) = @_;

   my $server = 'smtphost.qualcomm.com';
   my $recip = 'sirhoopsalot@gmail.com';
   my $subject = "Testing crawler : $instance_id";

   
   my %mail = (
            smtp    => $server,
            from    => 'jcen@qualcomm.com',
            to      => $recip,
            subject => $subject,
            'content-type' => 'text/plain; charset="iso-8859-1"',
   );
   
   $mail{body} = "$feed\n\r$title\n\r$date\n\r$desc\n\r$link\n";
   
   sendmail(%mail) || print "Error: $Mail::Sendmail::error\n";

}



sub print_to_log {
  my ($feed, $title, $link, $desc, $date, $author, $feed_name) = @_;
  
  $title =~ s/^\s+//g;
  $desc =~ s/^\s+//g;
  
  open (LOG, ">> $NEW_ARTICLES_FILE") or die "Can't open $NEW_ARTICLES_FILE ($!)";
  
  my $desc_text = '';
  my $p = HTML::Parser->new(text_h => [sub { $desc_text .= shift }, 'text'],
                             comment_h => [""],
                             );
  $p->parse($desc);
  
  $desc = $desc_text;
  #print ">>>$desc\n";
  
  
  my %ascii = ( feed  => $feed, 
                 title => $title, 
                 link  => $link, 
                 desc  => $desc,
                 date  => $date,
                 author=> $author,
                 feed_name => $feed_name,
                 feed_level => 1,   #TBD, hard code for now
  );
  print LOG Dumper(%ascii) . "\n";
  close LOG;

  
}

sub my_decode {
  my ($s) = @_;
  
  #$s =~ s/(.)/Unicode::String::utf8($1)->latin1()/eg;
  
  #$s =~ s/([\xc2-\xc3])([\x80-\xbf])/chr(64*ord($1&"\x03")+ord($2&"\x3f"))/eg;

  use utf8;
  use Text::Unidecode;
  $s = unidecode($s);
  
  #print "$s\n";

  return $s;
  
  eval { $s = decode('utf8', $s) }; die if $@;
  
  $s =~ s/&\#(\d\d\d\d);/chr($1)/egi;
  $s =~ s/&\#(\d\d);/chr($1)/egi;
  $s =~ s/&\#x(\w\w\w\w);/chr(hex($1))/egi;
  $s =~ s/&\#x(\w\w);/chr(hex($1))/egi;
  
  #eval { $s = decode('utf8', $s) }; die if $@;
  
  if (utf8::is_utf8($s)) {
    print "already utf8!\n"
  } else {
    decode('utf8', $s);
  }

  return $s;
}

sub queue_items {
   my ($title, $rss_url, $ref_arr) = @_;
   
   foreach my $i (0..1) {
     $_ = $ref_arr->[$i];
     last unless defined $_;
     my $headline = $_->title();
     $headline =~ s/^\s+//g;
     $headline =~ s/\s+$//g;
     chomp($headline);
     
      print "  " . $headline . "\n";

      print_to_log( $title || 'no title',
                    $headline || 'no headline',
                    $_->link() || 'no link',
                    $_->description() || 'no description',
                    $_->pubDate() || 'no date',
                    $_->author() || 'no author',
                    $rss_url || 'no feed name',
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
