class BbTeamsController < TeamsController
  before_filter :grab_top_reads

  def grab_teams
    @teams = BBTeam.find(:all)
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
    @team = BBTeam.find(params[:id])
  end

  def grab_top_reads
    @top_reads = BBArticle.find(:all, :order => "zscore desc", :conditions => "not (publication_name = \"http://search.espn.go.com/rss/david-thorpe/\" or publication_name = \"http://search.espn.go.com/rss/john-hollinger/\")", :limit => 5)
  end

  def grab_articles( conditions = nil )

    if conditions.nil?
      condition_statement = '(hide is null or hide = 0)'
    else
      condition_statement = conditions + ' and ( (hide is null or hide = 0) )'
    end

    #Team-relatednesss score:
    # need to weight each of these three factors when constructing a team page
    # 1) if team is mentioned in the title
    # 2) if team is associated with the rss feed
    # 3) if team is mentioned in the article text
    #w_title = 0.20
    w_title = 5.40
    #w_rss   = 0.15
    w_rss   = 5.50
    w_text  = 0.5
    w_penalty = 2 # divisor of score if it doesn't meet any of the above

    select_statement = 
      "select " +
           "*, case " +
    # contains all three factors, so give the highest score
    "when (title like '%#{@team.name}%' and text like '%#{@team.name}%' and teams_associated_with_url like '%#{@team.name}%') then score*(1+#{w_title}+(#{w_text}*2/(a.num_teams_mentioned + 1))+#{w_rss}) " + 
    
    # team in title and text but not associated with this rss, could be espn or yahoo
    "when (title like '%#{@team.name}%' and text like '%#{@team.name}%') then score*(1+#{w_title}+(#{w_text}*2/(a.num_teams_mentioned + 1))) " + 
    
    # team in title, associated with the rss, but not mentioned in text--unlikely, so treat as mistake
    "when (title like '%#{@team.name}%' and teams_associated_with_url like '%#{@team.name}%') then score/#{w_penalty} " +
    
    # team in title but not in text or associated with rss--unlikely, so treat as mistake
    "when (title like '%#{@team.name}%') then score/#{w_penalty} " + 

    # not in title, but in text and associated with rss
    "when (text like '%#{@team.name}%' and teams_associated_with_url like '%#{@team.name}%') then score*(1+(#{w_text}*2/(a.num_teams_mentioned + 1))+#{w_rss}) " + 

    # not in title, not associated with feed, but appears in text, just use the score withe some penalty
    "when (text like '%#{@team.name}%') then score*(1-(#{w_text}*2/(a.num_teams_mentioned + 1))) " +

    # not in title, not in text but associated with team--unlikely, so treat as mistake
    "when (teams_associated_with_url like '%#{@team.name}%') then score/#{w_penalty} " +

    # not in title, not associated with team, not in text, so push it down in list
    #"else score/#{w_penalty}/2 " + 
    "else score/40 " +

    "end as team_score " +

    "FROM articles a WHERE #{condition_statement} AND ( a.type = 'BBArticle'  ) ORDER BY team_score DESC"
    
    @articles = BBArticle.paginate_by_sql(select_statement, 
                                          :page => params[:page], 
                                          :total_entries => 300,
                                          :limit => 300,
                                          :per_page => 15)
  end

  
end

