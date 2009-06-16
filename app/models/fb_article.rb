class FBArticle < Article
  has_many :links
#  validates_uniqueness_of :url
  require 'nokogiri'
  require 'open-uri'


  def check_for_teams_mentioned( str )
    self[:teams_mentioned] = ""
    if( str =~ /Falcons/ ): self[:teams_mentioned] << "Falcons ";RUFUS_LOG.info "Falcons in article\n" end
    if( str =~ /Cardinals/ || str =~ /Cards/ ): self[:teams_mentioned] << "Cardinals "; RUFUS_LOG.info "Cardinals in article\n" end
    if( str =~ /Ravens/ ): self[:teams_mentioned] << "Ravens "; RUFUS_LOG.info "Ravens in article\n" end
    if( str =~ /Bills/ ): self[:teams_mentioned] << "Bills "; RUFUS_LOG.info "Bills in article\n" end
    if( str =~ /Panthers/ ): self[:teams_mentioned] << "Panthers "; RUFUS_LOG.info "Panthers in article\n" end
    if( str =~ /Bears/ ): self[:teams_mentioned] << "Bears "; RUFUS_LOG.info "Bears in article\n" end
    if( str =~ /Bengals/ ): self[:teams_mentioned] << "Bengals "; RUFUS_LOG.info "Bengals in article\n" end
    if( str =~ /Browns/ ): self[:teams_mentioned] << "Browns "; RUFUS_LOG.info "Browns in article\n" end
    if( str =~ /Cowboys/ ): self[:teams_mentioned] << "Cowboys "; RUFUS_LOG.info "Cowboys in article\n" end
    if( str =~ /Broncos/ ): self[:teams_mentioned] << "Broncos "; RUFUS_LOG.info "Broncos in article\n" end
    if( str =~ /Lions/ ): self[:teams_mentioned] << "Lions "; RUFUS_LOG.info "Lions in article\n" end
    if( str =~ /Packers/ ): self[:teams_mentioned] << "Packers "; RUFUS_LOG.info "Packers in article\n" end
    if( str =~ /Texans/ ): self[:teams_mentioned] << "Texans "; RUFUS_LOG.info "Texans in article\n" end
    if( str =~ /Colts/ ): self[:teams_mentioned] << "Colts "; RUFUS_LOG.info "Colts in article\n" end
    if( str =~ /Jaguars/ ): self[:teams_mentioned] << "Jaguars "; RUFUS_LOG.info "Jaguars in article\n" end
    if( str =~ /Chiefs/ ): self[:teams_mentioned] << "Chiefs "; RUFUS_LOG.info "Chiefs in article\n" end
    if( str =~ /Dolphins/ ): self[:teams_mentioned] << "Dolphins "; RUFUS_LOG.info "Dolphins in article\n" end
    if( str =~ /Vikings/ ): self[:teams_mentioned] << "Vikings "; RUFUS_LOG.info "Vikings in article\n" end
    if( str =~ /Patriots/ || str =~ /Pats/ ): self[:teams_mentioned] << "Patriots "; RUFUS_LOG.info "Patriots in article\n" end
    if( str =~ /Saints/ ): self[:teams_mentioned] << "Saints "; RUFUS_LOG.info "Saints in article\n" end
    if( str =~ /Giants/ ): self[:teams_mentioned] << "Giants "; RUFUS_LOG.info "Giants in article\n" end
    if( str =~ /Jets/ ): self[:teams_mentioned] << "Jets "; RUFUS_LOG.info "Jets in article\n" end
    if( str =~ /Raiders/ ): self[:teams_mentioned] << "Raiders "; RUFUS_LOG.info "Raiders in article\n" end
    if( str =~ /Eagles/ ): self[:teams_mentioned] << "Eagles "; RUFUS_LOG.info "Eagles in article\n" end
    if( str =~ /Steelers/ ): self[:teams_mentioned] << "Steelers "; RUFUS_LOG.info "Steelers in article\n" end
    if( str =~ /Chargers/ || str =~ /Bolts/ ): self[:teams_mentioned] << "Chargers "; RUFUS_LOG.info "Chargers in article\n" end
    if( str =~ /Rams/ ): self[:teams_mentioned] << "Rams "; RUFUS_LOG.info "Rams in article\n" end
    if( str =~ /49ers/ ): self[:teams_mentioned] << "49ers "; RUFUS_LOG.info "49ers in article\n" end
    if( str =~ /Titans/ ): self[:teams_mentioned] << "Titans "; RUFUS_LOG.info "Titans in article\n" end
    if( str =~ /Buccaneers/ || str =~ /Bucs/ ): self[:teams_mentioned] << "Buccaneers "; RUFUS_LOG.info "Buccaneers in article\n" end
    if( str =~ /Redskins/ || str =~ /Skins/ ): self[:teams_mentioned] << "Redskins "; RUFUS_LOG.info "Redskins in article\n" end
    if( str =~ /Seahawks/ || str =~ /Hawks/ ): self[:teams_mentioned] << "Seahawks "; RUFUS_LOG.info "Seahawks in article\n" end

  end

  def check_for_players_mentioned( str )
    #jlk todo
    str
  end

end
