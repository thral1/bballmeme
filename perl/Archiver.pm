#! perl -w

package Archiver;

use strict;

my $BASE_TABLE = q{deviagaz_bballmeme.articles};
my $count = 0;

sub new {
  my ( $class, %args ) = @_;
  
  #print "got new call ".$args{db}." ".$args{tbl}."\n";
  
  my $dbh = $args{dbh};
  my $sth = $dbh->prepare("SHOW tables like '$args{tbl}'");
  
  $sth->execute();
  my $tbl_exists = 0;
  while ($sth->fetchrow_array()) {
  	# got something, so the table must exist
  	$tbl_exists = 1;
  }
  
  if (!$tbl_exists) {
  	$sth = $dbh->prepare("CREATE table $args{tbl} like $BASE_TABLE");
  	$sth->execute();
  	print STDERR "Created new table ".$args{db}.".".$args{tbl}."\n";
  } else {
  	print "Table already exists ".$args{db}.".".$args{tbl}.". No need to create\n";
  } 
    
  return bless(\%args, $class);
}

sub before_begin {
	my ( $self, %args ) = @_;
	# Save column names for later
	$self->{cols} = $args{cols};
}

sub is_archivable {
	my ( $self, %args ) = @_;
	# Do some advanced logic with $args{row}
	return 1;
}

sub before_insert {
	my ($self, %args) = @_;
	
	my $row_ref = $args{row};
	print "Archive row with ID ".$row_ref->[0]."\n";
        $count++;
}

sub before_delete {
	my ($self, %args) = @_;

	my $row_ref = $args{row};
	my $row_id = $row_ref->[0];
	print "Archive row with ID $row_id\n";

	# get a list of links that come from this article
	my $dbh = $args{dbh};
	my $sth = $dbh->prepare("select a.link_id from articles r, articles_links a where
a.article_id = r.id
and r.id = $row_id");
  	$sth->execute();
	# delete each link record for this article
	while ($sth->fetchrow_array()) {
  		my $link_id = $_;
		my $sth2 = $dbh->prepare("delete from links l where l.id = $link_id");
		$sth2->execute();
		my $sth3 = $dbh->prepare("delete from articles_links a where a.link_id = $link_id");
		$sth3->execute();
		print STDERR (" deleting links with ID link_id\n");
  	}

} 
sub custom_sth    {} # Take no action
sub after_finish  {
    print STDERR "Archived $count articles\n";
} # Take no action

1;

__END__

