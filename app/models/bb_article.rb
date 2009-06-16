class BBArticle < Article
  has_many :links
#  validates_uniqueness_of :url
  require 'nokogiri'
  require 'open-uri'

  def check_for_teams_mentioned( str )
    self[:teams_mentioned] = ""
    self[:num_teams_mentioned] = 0
    if( str =~ /Hawks/ ): self[:teams_mentioned] << "Hawks ";RUFUS_LOG.info "Hawks in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Celtics/ ): self[:teams_mentioned] << "Celtics "; RUFUS_LOG.info "Celtics in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Bobcats/ ): self[:teams_mentioned] << "Bobcats "; RUFUS_LOG.info "Bobcats in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Bulls/ ): self[:teams_mentioned] << "Bulls "; RUFUS_LOG.info "Bulls in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1;self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Cavaliers/ || str =~ /Cavs/ ): self[:teams_mentioned] << "Cavaliers "; RUFUS_LOG.info "Cavaliers in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Mavericks/ || str =~ /Mavs/ ): self[:teams_mentioned] << "Mavericks "; RUFUS_LOG.info "Mavericks in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Nuggets/ || str =~ /Nugs/ ): self[:teams_mentioned] << "Nuggets "; RUFUS_LOG.info "Nuggets in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Pistons/ ): self[:teams_mentioned] << "Pistons "; RUFUS_LOG.info "Pistons in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Warriors/ ): self[:teams_mentioned] << "Warriors "; RUFUS_LOG.info "Warriors in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Rockets/ || str =~ /Rox/ ): self[:teams_mentioned] << "Rockets "; RUFUS_LOG.info "Rockets in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Pacers/ ): self[:teams_mentioned] << "Pacers "; RUFUS_LOG.info "Pacers in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Clippers/ || str =~ /Clips/ ): self[:teams_mentioned] << "Clippers "; RUFUS_LOG.info "Clippers in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Lakers/ ): self[:teams_mentioned] << "Lakers "; RUFUS_LOG.info "Lakers in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Grizzlies/ || str =~ /Grizz/ || str =~ /Griz/ ): self[:teams_mentioned] << "Grizzlies "; RUFUS_LOG.info "Grizzlies in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Heat/ ): self[:teams_mentioned] << "Heat "; RUFUS_LOG.info "Heat in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Bucks/ ): self[:teams_mentioned] << "Bucks "; RUFUS_LOG.info "Bucks in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Timberwolves/ || str =~ /TWolves/i || str =~ /Wolves/ ): self[:teams_mentioned] << "Timberwolves "; RUFUS_LOG.info "Timberwolves in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Nets/ ): self[:teams_mentioned] << "Nets "; RUFUS_LOG.info "Nets in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Hornets/ ): self[:teams_mentioned] << "Hornets "; RUFUS_LOG.info "Hornets in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Knicks/ ): self[:teams_mentioned] << "Knicks "; RUFUS_LOG.info "Knicks in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Thunder/ ): self[:teams_mentioned] << "Thunder "; RUFUS_LOG.info "Thunder in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Magic/ ): self[:teams_mentioned] << "Magic "; RUFUS_LOG.info "Magic in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /76ers/ || str =~ /Sixers/ ): self[:teams_mentioned] << "Sixers "; RUFUS_LOG.info "Sixers in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Suns/ ): self[:teams_mentioned] << "Suns "; RUFUS_LOG.info "Suns in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Trail Blazers/ || str =~ /Blazers/ ): self[:teams_mentioned] << "Trail Blazers "; RUFUS_LOG.info "Trail Blazersin article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Kings/ ): self[:teams_mentioned] << "Kings "; RUFUS_LOG.info "Kings in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Spurs/ ): self[:teams_mentioned] << "Spurs "; RUFUS_LOG.info "Spurs in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Raptors/ || str =~ /Raps/ ): self[:teams_mentioned] << "Raptors "; RUFUS_LOG.info "Raptors in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Jazz/ ): self[:teams_mentioned] << "Jazz "; RUFUS_LOG.info "Jazz in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    if( str =~ /Wizards/ || str =~ /Wiz/ ): self[:teams_mentioned] << "Wizards "; RUFUS_LOG.info "Wizards in article\n";self[:num_teams_mentioned] = self[:num_teams_mentioned] + 1 end
    return self[:teams_mentioned]
  end


  def check_for_players_mentioned( str )
    self[:players_mentioned] = ""
    if( str =~ /Kobe/ && str =~ /Bryant/ ): self[:players_mentioned] << "Kobe Bryant "; RUFUS_LOG.info "Chauncey Billups in article\n" end
    if( str =~ /Lebron/i ): self[:players_mentioned] << "Lebron James "; RUFUS_LOG.info "Chauncey Billups in article\n" end
    if( str =~ /Billups/ ): self[:players_mentioned] << "Chauncey Billups "; RUFUS_LOG.info "Chauncey Billups in article\n" end
    if( str =~ /Dirk/ && str =~ /Nowitzki/ ): self[:players_mentioned] << "Dirk Nowitzki "; RUFUS_LOG.info "Dirk Nowitzki in article\n" end
    if( str =~ /Dwyane/ && str =~ /Wade/ ): self[:players_mentioned] << "Dwyane Wade "; RUFUS_LOG.info "Chauncey Billups in article\n" end
    if( str =~ /Danny/ && str =~ /Granger/ ): self[:players_mentioned] << "Danny Granger "; RUFUS_LOG.info "Chauncey Billups in article\n" end
    if( str =~ /Kevin/ && str =~ /Durant/ ): self[:players_mentioned] << "Kevin Durant "; RUFUS_LOG.info "Chauncey Billups in article\n" end
    if( str =~ /Chris/ && str =~ /Paul/ ): self[:players_mentioned] << "Chris Paul "; RUFUS_LOG.info "Chris Paul in article\n" end
    if( str =~ /Carmelo/ && str =~ /Anthony/ ): self[:players_mentioned] << "Carmelo Anthony "; RUFUS_LOG.info "Carmelo Anthony in article\n" end
    if( str =~ /Chris/ && str =~ /Bosh/ ): self[:players_mentioned] << "Chris Bosh "; RUFUS_LOG.info "Chris Bosh in article\n" end
    if( str =~ /Brandon/ && str =~ /Roy/ ): self[:players_mentioned] << "Brandon Roy "; RUFUS_LOG.info "Brandon Roy in article\n" end
    if( str =~ /Antawn/ && str =~ /Jamison/ ): self[:players_mentioned] << "Antawn Jamison "; RUFUS_LOG.info "Antawn Jamison in article\n" end
    if( str =~ /Tony/ && str =~ /Parker/ ): self[:players_mentioned] << "Tony Parker "; RUFUS_LOG.info "Tony Parker in article\n" end
    if( str =~ /Joe/ && str =~ /Johnson/ ): self[:players_mentioned] << "Joe Johnson "; RUFUS_LOG.info "Joe Johnson in article\n" end
    if( str =~ /Devin/ && str =~ /Harris/ ): self[:players_mentioned] << "Devin Harris "; RUFUS_LOG.info "Devin Harris in article\n" end
    if( str =~ /David/ && str =~ /West/ ): self[:players_mentioned] << "David West "; RUFUS_LOG.info "David West in article\n" end
    if( str =~ /Vince/ && str =~ /Carter/ ): self[:players_mentioned] << "Vince Carter "; RUFUS_LOG.info "Vince Carter in article\n" end
    if( str =~ /Ben/ && str =~ /Gordon/ ): self[:players_mentioned] << "Ben Gordon "; RUFUS_LOG.info "Ben Gordon in article\n" end
    if( str =~ /Dwight/ && str =~ /Howard/ ): self[:players_mentioned] << "Dwight Howard "; RUFUS_LOG.info "Dwight Howard in article\n" end
    if( str =~ /Paul/ && str =~ /Pierce/ ): self[:players_mentioned] << "Paul Pierce "; RUFUS_LOG.info "Paul Pierce in article\n" end
    if( str =~ /Al/ && str =~ /Harrington/ ): self[:players_mentioned] << "Al Harrington "; RUFUS_LOG.info "Al Harrington in article\n" end
    if( str =~ /Yao/ && str =~ /Ming/ ): self[:players_mentioned] << "Yao Ming "; RUFUS_LOG.info "Yao Ming in article\n" end
    if( str =~ /Tim/ && str =~ /Duncan/ ): self[:players_mentioned] << "Tim Duncan "; RUFUS_LOG.info "Tim Duncan in article\n" end
    if( str =~ /Shaquille/ && str =~ /O'Neal/ ): self[:players_mentioned] << "Shaquille O'Neal "; RUFUS_LOG.info "Shaq in article\n" end
    if( str =~ /Steve/ && str =~ /Nash/ ): self[:players_mentioned] << "Steve Nash "; RUFUS_LOG.info "Steve Nash in article\n" end
    if( str =~ /Jose/ && str =~ /Calderon/ ): self[:players_mentioned] << "Jose Calderon "; RUFUS_LOG.info "Jose Calderon in article\n" end
    if( str =~ /Rajon/ && str =~ /Rondo/ ): self[:players_mentioned] << "Rajon Rondo "; RUFUS_LOG.info "Rajon Rondo in article\n" end
    if( str =~ /Baron/ && str =~ /Davis/ ): self[:players_mentioned] << "Baron Davis "; RUFUS_LOG.info "Baron Davis in article\n" end
    if( str =~ /Raymond/ && str =~ /Felton/ ): self[:players_mentioned] << "Raymond Felton "; RUFUS_LOG.info "Raymond Felton in article\n" end
    if( str =~ /Derrick/ && str =~ /Rose/ ): self[:players_mentioned] << "Derrick Rose "; RUFUS_LOG.info "Derrick Rose in article\n" end
    if( str =~ /Russell/ && str =~ /Westbrook/ ): self[:players_mentioned] << "Russell Westbrook "; RUFUS_LOG.info "Russell Westbrook in article\n" end
    if( str =~ /Josh/ && str =~ /Smith/ ): self[:players_mentioned] << "Josh Smith "; RUFUS_LOG.info "Josh Smith in article\n" end
    if( str =~ /Amare/ && str =~ /Stoudemire/ ): self[:players_mentioned] << "Amare Stoudemire "; RUFUS_LOG.info "Amare Stoudemire in article\n" end
    if( str =~ /David/ && str =~ /Lee/ ): self[:players_mentioned] << "David Lee "; RUFUS_LOG.info "David Lee in article\n" end
    if( str =~ /Paul/ && str =~ /Millsap/ ): self[:players_mentioned] << "Paul Millsap "; RUFUS_LOG.info "Paul Millsap in article\n" end
    if( str =~ /Kevin/ && str =~ /Garnett/ ): self[:players_mentioned] << "Kevin Garnett "; RUFUS_LOG.info "Kevin Garnett in article\n" end
    if( str =~ /Brook/ && str =~ /Lopez/ ): self[:players_mentioned] << "Brook Lopez "; RUFUS_LOG.info "Brook Lopez in article\n" end
    if( str =~ /Al/ && str =~ /Horford/ ): self[:players_mentioned] << "Al Horford "; RUFUS_LOG.info "Al Horford in article\n" end
    if( str =~ /Grant/ && str =~ /Hill/ ): self[:players_mentioned] << "Grant Hill "; RUFUS_LOG.info "Grant Hill in article\n" end
    if( str =~ /Boris/ && str =~ /Diaw/ ): self[:players_mentioned] << "Boris Diaw "; RUFUS_LOG.info "Boris Diaw in article\n" end
    if( str =~ /Gerald/ && str =~ /Wallace/ ): self[:players_mentioned] << "Gerald Wallace "; RUFUS_LOG.info "Gerald Wallace in article\n" end
    if( str =~ /Trevor/ && str =~ /Ariza/ ): self[:players_mentioned] << "Trevor Ariza "; RUFUS_LOG.info "Trevor Ariza in article\n" end
    if( str =~ /Andre/ && str =~ /Iguodala/ ): self[:players_mentioned] << "Andre Iguodala "; RUFUS_LOG.info "Andre Iguodala in article\n" end
  end

  
end
