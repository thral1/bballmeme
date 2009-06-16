class FbArticlesController < ArticlesController
  before_filter :grab_top_reads

  def grab_teams
    @teams = FBTeam.find(:all)
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
  end

  def grab_top_reads
    @top_reads = FBArticle.find(:all, :order => "zscore desc", :limit => 5)
  end

  def grab_articles( conditions = nil ) 

    if conditions.nil?
      condition_statement = '(hide is null or hide = 0)'
    else
      condition_statement = conditions + ' and (hide is null or hide = 0)'
    end

    @articles = FBArticle.paginate(:page => params[:page], :per_page => 15,
				                         :order => 'score DESC',
				                         :conditions => condition_statement )
  end

end
