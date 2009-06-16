class ArticlesController < ApplicationController
  # GET /articles
  # GET /articles.xml

  caches_action :index, :cache_path => Proc.new {|controller| controller.params }
  caches_action :main, :cache_path => Proc.new {|controller| controller.params }
  caches_action :news, :cache_path => Proc.new {|controller| controller.params }
  caches_action :blogs, :cache_path => Proc.new {|controller| controller.params }
  before_filter :grab_teams#, :grab_articles

  def grab_teams
    @teams = Team.find(:all)
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
  end

  def refresh_cache
    expire_page :controller => 'articles', :action => 'index'
    expire_page :action => 'index'
    expire_page :action => 'main'
    expire_page :action => 'national'
    expire_page :action => 'local'
    expire_page :action => 'blogs'
  end

  def grab_articles( conditions = nil ) 
    #@articles = Article.find(:all)
    if @articles.nil?
      flash[:notice] = "There are no articles\n"
    end

    if conditions.nil?
      condition_statement = '(hide is null or hide = 0) and score > 0'
    else
      condition_statement = conditions + 
                            ' and ( (hide is null or hide = 0) and score > 0)'
    end

    @articles = Article.paginate(:page => params[:page], 
                                 :per_page => 15,
				 :order => 'score DESC',            
                                 :conditions => condition_statement )
  end

  def get_links
    @articles = Article.find(:all)
    @articles.each{ |article|
      article.get_links
    }
    render( :action => :index )
  end

  def reevaluate_all_articles
    Article.reevaluate_all_articles
    render( :action => :index )
  end

  def eval_single_article
    @article = Article.new
    flash[:notice] = params[:url].to_s
    @article.evaluate_article( params[:url].to_s )
    render( :action => :index )
  end

  def get_comments
    @article = Article.new
    flash[:notice] = params[:url].to_s
    @article.get_number_of_comments( params[:url].to_s )
    render( :action => :index )
  end

  def news
    grab_articles( "(article_type like \"%local%\" or article_type like \"%national%\") " ) 
  end

  def blogs 
    grab_articles( "article_type like \"%blog%\" " ) 
  end

  def main
    redirect_to :action => "index"
  end

  def index
     grab_articles( )
=begin
    @articles = Article.find(:all)
    @articles.each{ |article|
      article.evaluate_article( article.url )
    }
    @articles = Article.paginate(:page => params[:page], :per_page => 10)
=end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = Article.new(params[:article])

    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to(@article) }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to(@article) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end
end
