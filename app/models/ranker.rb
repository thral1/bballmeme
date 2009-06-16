class Ranker
require 'logger'
require 'active_record'

    rufus_logfile = File.open("/home/deviagaz/bballmeme/log/sched.log", 'a')
    rufus_logfile.sync = true
    RUFUS_LOG = Logger.new(rufus_logfile)

  def initialize
    #RUFUS_LOG = RAILS_DEFAULT_LOGGER
    @sql = ActiveRecord::Base.establish_connection(
            :adapter => 'mysql',
            :database => 'deviagaz_bballmeme',
            :username => 'deviagaz_rails',
            :password => 'password',
            :host => 'localhost',
            :port => 3306
            )
=begin
    @sql = ActiveRecord::Base.establish_connection(
            :adapter => 'sqlite3',
            :database => '/home/deviagaz/bballmeme/db/production.sqlite3',
            :timeout => 15000
            )
        #sql = ActiveRecord::Base.connection();
=end

  end

  $category_weights = {
		      "num_comments"		=> 0.4,
		      "num_backward_links" 	=> 0.4,
		      "num_visitors_per_month"  => 0.1,
		      "publication"		=> 0.05,
		      "author"			=> 0.05,
		      "feed_level"		=> 0.05,
		      # doesn't add up to 100% but good enough for now
		      }
		      

  $publication_bias = {
	  	     "espn.com" => 1500,
		     "cnn.com"  => 1000,
		     "<other>"  => 100,
		     }

  $author_bias = {
	        "Inside Hoops" => 1500,
	        "Arsenalist"   => 1300,
	        "Frank Madden" => 1200,
	        "<other>"      => 100,
	        }


  $rss_feed_level_bias = {
	                 "espn.com top stories" => 1500,
	                  "<other>"             => 100,
		        }			

  $recap_penalty = 555.5  # totally arbitrary at this point

  def visitors_per_month_normalize(x)
    # x in thousands of visitors a month
    # returns a sigmoid function that starts around 1.0 and tops out at 1.5
    # return value is almost 1.5 near 1M users
    y = (2000 / (1+Math.exp((1000000-x)/200000)) + 1.0)

    # return a linear scale of the number of visitors per month for the site
    #  assume that 2000 is a really high normalized score
    #  assume that 7M is a really high number of visitors per month
    #  our normalization algorithm should map the two 
    #y = x / 3500

    RUFUS_LOG.debug "  visitors per month normalized: #{y} = f of #{x}"
    return y
  end

  def backward_links_normalize(x)
    # x in number of links
    # returns an monotonically increasing function starting at 1.0
    #y = (1.0 + Math.log(Math.sqrt(x/10+1)))
    
    # returns a linear scale of the number of backward_links
    #  assume that 2000 is a really high normalized score
    #  assume that 10 is a really high number of backward links
    #  our normalization algorithm should map the two; and we'll use linear interpolation for now
    #y = x * 200.0

    # return a logarithm of the number of links
    y = Math.log(x+1)*1000;    

    RUFUS_LOG.debug "  backward links normalized: #{y} = f of #{x}"
    return y
  end

  def comments_normalize(x)
    # x in number of comments
    # returns a linear scale of the number of comments
    #  assume that 2000 is a really high normalized score
    #  assume that 400 is a really high number of comments
    #  our normalization algorithm should map the two; and we'll use linear interpolation for now
    #y = x * 5.0

    # return a logarithm of the number of comments
    y = Math.log(x+1)*750

    RUFUS_LOG.debug "  num comments normalized: #{y} = f of #{x}"
    
    return y
  end

  def age(t)
    # pass in time of publication t
    # return time in second since article was published from some arbitrary reference date (say 1/1/2009)
    
    if t.nil?
      delta = 0
    else
      ref = DateTime.new(2009, 1, 1) 
      pub = DateTime.new(t.year, t.month, t.day)
      delta = pub - ref  # delta in days
      delta = delta * 60 * 60 * 24.0  # delta in seconds
      delta = delta.to_i

      RUFUS_LOG.debug "  age is #{delta}"
    end

    if delta > (365 * 24 * 60 * 60)
      RUFUS_LOG.warn "  publication date is over a year old !!"
    end
    return delta
  end

  def z_score(article)
    z = 0

    # this function needs to be consistent with the sql query in rescore_articles()
    # we will need to implement

    #RUFUS_LOG.debug "before pub bias"
    if $publication_bias[article.publication].nil?
      #z += $category_weights["publication"] * $publication_bias["<other>"]
    else 
      #z += $category_weights["publication"] * $publication_bias[article.publication]
    end

    #RUFUS_LOG.debug "before author bias"
    if $author_bias[article.author].nil?
      #z += $category_weights["author"] * $author_bias["<other>"]
    else
      #z += $category_weights["author"] * $author_bias[article.author]
    end

    #RUFUS_LOG.debug "before feed bias"
    if $rss_feed_level_bias[article.rss_feed_level].nil?
      #z += $category_weights["feed_level"] * $rss_feed_level_bias["<other>"]
    else 
      #z += $category_weights["feed_level"] * $rss_feed_level_bias[article.rss_feed_level]
    end

    #RUFUS_LOG.debug "before vistors"
    if article.num_visitors_per_month.nil?
      article.num_visitors_per_month  = 0
    end
    visitors_per_month_normalize(article.num_visitors_per_month * 1.0)

    z += $category_weights["num_visitors_per_month"] * visitors_per_month_normalize(article.num_visitors_per_month * 1.0)

    #RUFUS_LOG.debug "before comments"
    if article.num_comments.nil?
      article.num_comments = 0
      article.save
    end
    comments_normalize(article.num_comments * 1.0)
    z += $category_weights["num_comments"] * comments_normalize(article.num_comments * 1.0)

    #RUFUS_LOG.debug "before links #{article.num_backward_links}"
    z += $category_weights["num_backward_links"] * backward_links_normalize(article.num_backward_links * 1.0)
    
    # check to see if the article is a recap
    if article.article_type =~ /recap/
      z -= $recap_penalty
    end

    #RUFUS_LOG.debug "before return of z score"
    if z <= 0
      z = 1  # z cannot be less <= zero because we take the log if it
    end
    return z
  end

  def get_article_comments
    articles = Article.find :all
      if articles.nil?
        RUFUS_LOG.debug "no articles in database!"
	    return
      else
        RUFUS_LOG.debug "going to calculate the comments for #{articles.size} records"
      end

        RUFUS_LOG.debug "get article comments!"
      articles.each do |a|
        RUFUS_LOG.debug "get article comments for: #{a.url}"
    begin
        doc = Hpricot( open( a.url ) )
    rescue Exception
        RUFUS_LOG.debug "exception in open #{url} in ranker, get comments()"
        puts "exception in open #{url} in ranker, get comments()"
    end
        a.get_number_of_comments( a.url, doc )

      end
        RUFUS_LOG.debug "done get article comments!"

  end

  def rescore_articles
      RUFUS_LOG.debug "going to score all the articles #{ENV['GEM_PATH']}"
      
      # rescore the articles 
      begin
        age_factor = 3.0; # set lower to penalize older articles more
        secs_in_day = 86400;
        
        @sql = ActiveRecord::Base.connection();
        @sql.execute "SET autocommit=0";
        @sql.begin_db_transaction
        @sql.update "UPDATE articles SET age = (UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(publication_date))";
        @sql.update "UPDATE articles SET zscore = (
      (.1 * ( ( 2000 / (1+EXP((1000000-num_visitors_per_month)/200000)) + 1.0))) +
      (.4 * (LOG10(num_backward_links+1)*1000)) +
      (.4 * (LOG10(num_comments+1)*750)) -
      (case when article_type like '%recap%' then #{$recap_penalty} else 0 end)
      )";
            #(.1 * (feed_score*1500)) +

        @sql.update "UPDATE articles SET score = ((LOG10(zscore) - POW(2,age/#{secs_in_day})/#{age_factor}) * 1000)";
        #This statement replaces a.calculate_inbound_links()
        @sql.update "UPDATE articles a SET a.num_backward_links = (SELECT COUNT(*) from links l where l.url = a.url)"
        @sql.update "UPDATE articles SET updated_at = now()"
        @sql.commit_db_transaction
      end
      0

  end 

end


