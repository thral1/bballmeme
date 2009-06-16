class FeedsController < ApplicationController
  # GET /feeds
  # GET /feeds.xml
  def index
    #@feeds = Feed.find(:all)

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.xml  { render :xml => @feeds }
    #end
    
    #dir = `pwd` + "\/perl\/crawler.pl"
    #result = system("perl perl\\crawler.pl");
    #@lines = "nothing here buddy"; #result.split('\n');
    #result = `pwd`
    
    # open the fifo text file which tells us which file to open and where to read from
    fifo = File.open("perl\/fifo.txt", "r+")
    article_file = fifo.gets.chomp   # first line is the article file name
    pos = fifo.gets            # second line is the index
    fifo.close
    
    counter = 0
    left_off = 0;
    @lines = Array.new
    File.open(article_file, "r") do |file|
      file.seek(pos.to_i)           # go to where we left off
      url = String.new
      date = String.new
      feed = String.new
      desc = String.new
      title = String.new
      author = String.new
      feed_name = String.new
      feed_level = 0
      while (line = file.gets)
          #puts "#{counter}: #{line}"
          #@lines << "#{counter}: #{line}";
          if /\$VAR1 =/ =~ line
            if !url.empty?
              #flush what you have
              @lines << "link => #{url}"
              @lines << "title => #{title}"
              @lines << "feed_name => #{feed_name}"
              @lines << "date => #{date}"
              @lines << "feed => #{feed}"
              @lines << "desc => #{desc}"
              @lines << "author => #{author}"
              @lines << "feed_level => #{feed_level}"
              @lines << "================"
              a = Article.create(:url => url, :title => title, :publication_date => date, :rss_feed_level => feed_level, :rss_description => desc, :author => author, :publication_name => feed_name)
              a.evaluate_article
              # feed_level : 1 default, 2 for more important articles
              
              # increment counter 
              counter = counter + 1
              
              # clear out all states
              url = ''
              title = ''
              date = ''
              feed = ''
              desc = ''
              author = ''
              feed_name = ''
              feed_level = 0
            end 
          end 
          
          if /\$VAR\d+ = 'link'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              url = $1 
            end
          elsif /\$VAR\d+ = 'feed'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              feed = $1 
            end
            #feed = file.gets.split("=",2)[1]
          elsif /\$VAR\d+ = 'date'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              date = $1 
            end
            #date = file.gets.split("=",2)[1]
          elsif /\$VAR\d+ = 'desc'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              desc = $1
              #desc.gsub(/\\'/, '\'')
            end
            #desc = file.gets.split("=",2)[1][0..127]
          elsif /\$VAR\d+ = 'title'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              title = $1 
            end
            #title = file.gets.split("=",2)[1]
          elsif /\$VAR\d+ = 'author'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              author = $1 
            end
            #author = file.gets.split("=",2)[1]
          elsif /\$VAR\d+ = 'feed_name'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              feed_name = $1 
            end
            #feed_name = file.gets.split("=",2)[1]
          elsif /\$VAR\d+ = 'feed_level'/ =~ line
            if file.gets =~ /\$VAR\d+ = (.*);/
              feed_level = $1 
            end
            #feed_level = file.gets.split("=",2)[1]
          end
          
      end
      left_off = file.pos
      file.close
    end
    
    
    # TBD. set back to zero for now
    #left_off = 0

    # save where we left off for next time
    fifo = File.open("perl\\fifo.txt", "w")
    fifo.puts article_file
    fifo.puts left_off
    fifo.close
    
    flash[:notice] = "POS: #{left_off}; #{counter} new article(s) since last refresh of this page "
    

    
  end

  # GET /feeds/1
  # GET /feeds/1.xml
  def show
    @feed = Feed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed }
    end
  end

  # GET /feeds/new
  # GET /feeds/new.xml
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed }
    end
  end

  # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
  end

  # POST /feeds
  # POST /feeds.xml
  def create
    @feed = Feed.new(params[:feed])

    respond_to do |format|
      if @feed.save
        flash[:notice] = 'Feed was successfully created.'
        format.html { redirect_to(@feed) }
        format.xml  { render :xml => @feed, :status => :created, :location => @feed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feeds/1
  # PUT /feeds/1.xml
  def update
    @feed = Feed.find(params[:id])

    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        flash[:notice] = 'Feed was successfully updated.'
        format.html { redirect_to(@feed) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.xml
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy

    respond_to do |format|
      format.html { redirect_to(feeds_url) }
      format.xml  { head :ok }
    end
  end
end
