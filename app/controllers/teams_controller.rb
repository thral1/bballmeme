class TeamsController < ApplicationController
  # GET /teams
  # GET /teams.xml

  layout 'articles'
  before_filter :grab_teams

  caches_page :show, :main, :news, :blogs
  def grab_teams
    @teams = Team.find(:all)
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
    @team = Team.find(params[:id])
  end

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teams }
    end
  end

  def news
    grab_articles( "(article_type like '%local%' or article_type like '%national%') " ) 
  end

  def blogs 
    grab_articles( "article_type like \"%blog%\" " ) 
  end

  def main
    #redirect_to :action => "show", :id => params[:id]
    redirect_to "/teams/#{@team.name}"
  end


  def grab_articles( conditions = nil )

    if conditions.nil?
      condition_statement = '(hide is null or hide = 0) and score > 0'
    else
      condition_statement = conditions + ' and ( (hide is null or hide = 0) and score > 0)'
    end

    #Team-relatednesss score:
    # need to weight each of these three factors when constructing a team page
    # 1) if team is mentioned in the title
    # 2) if team is associated with the rss feed
    # 3) if team is mentioned in the article text
    w_title = 0.20
    w_rss   = 0.15
    w_text  = 0.05
    w_penalty = 2 # divisor of score if it doesn't meet any of the above

    select_statement = 
           "*, case " +
    # contains all three factors, so give the highest score
    "when (title like '%#{@team.name}%' and text like '%#{@team.name}%' and teams_associated_with_url like '%#{@team.name}%') then score*(1+#{w_title}+#{w_text}+#{w_rss}) " + 
    
    # team in title and text but not associated with this rss, could be espn or yahoo
    "when (title like '%#{@team.name}%' and text like '%#{@team.name}%') then score*(1+#{w_title}+#{w_text}) " + 
    
    # team in title, associated with the rss, but not mentioned in text--unlikely, so treat as mistake
    "when (title like '%#{@team.name}%' and teams_associated_with_url like '%#{@team.name}%') then score/#{w_penalty} " +
    
    # team in title but not in text or associated with rss--unlikely, so treat as mistake
    "when (title like '%#{@team.name}%') then score/#{w_penalty} " + 

    # not in title, but in text and associated with rss
    "when (text like '%#{@team.name}%' and teams_associated_with_url like '%#{@team.name}%') then score*(1+#{w_text}+#{w_rss}) " + 

    # not in title, not associated with feed, but appears in text, just use the score withe some penalty
    "when (text like '%#{@team.name}%') then score*(1-#{w_text}) " +

    # not in title, not in text but associated with team--unlikely, so treat as mistake
    "when (teams_associated_with_url like '%#{@team.name}%') then score/#{w_penalty} " +

    # not in title, not associated with team, not in text, so push it down in list
    #"else score/#{w_penalty}/2 " + 
    "else score/4 " +

    "end as team_score"

    @articles = Article.paginate(:page => params[:page], :per_page => 15,
                                 :order => 'team_score DESC',
                                 :conditions => condition_statement,
                                 :select => select_statement)

  end

  # GET /teams/1
  # GET /teams/1.xml
  def show

    grab_articles

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        flash[:notice] = 'Team was successfully created.'
        format.html { redirect_to(@team) }
        format.xml  { render :xml => @team, :status => :created, :location => @team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.xml
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Team was successfully updated.'
        format.html { redirect_to(@team) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.xml
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(teams_url) }
      format.xml  { head :ok }
    end
  end
end
