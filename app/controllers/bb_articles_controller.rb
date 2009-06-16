class BbArticlesController < ArticlesController

  before_filter :grab_top_reads

  def grab_teams
    @teams = BBTeam.find(:all)
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
  end

  def grab_top_reads
    @top_reads = BBArticle.find(:all, :order => "zscore desc", :conditions => "not (publication_name = \"http://search.espn.go.com/rss/david-thorpe/\" or publication_name = \"http://search.espn.go.com/rss/john-hollinger/\")", :limit => 5)
  end

  def grab_articles( conditions = nil ) 

    if conditions.nil?
      condition_statement = '(hide is null or hide = 0)'
    else
      condition_statement = conditions + 
                            ' and (hide is null or hide = 0) '
    end

    @articles = BBArticle.paginate(:page => params[:page], 
                                   :per_page => 15,
                                   :order => 'score DESC', 
                                   :total_entries=> 300,
                                   :conditions => condition_statement )
  end

end
