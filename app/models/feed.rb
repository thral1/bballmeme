class Feed < ActiveRecord::Base
  validates_uniqueness_of :url

  require 'nokogiri'
  require 'open-uri'
  
  @@recursion_level = 1  

  def discover_new_feeds
    # get all the articles in our database as a seed
    articles = get_articles_to_crawl()
    
    num_new_feeds = find_feeds_recursive(articles)

    return num_new_feeds
  end

  def find_feeds_recursive(articles)

    new_feeds = []
    new_links = {}

    if (articles.size <= 0)
      print "empty...done\n"
      return 0
    end
    
    # go through each one
    articles.keys.each do |art| 
      url = art.url
    
      unless (url.to_s =~ /^http:\/\//)
        #print "skipping url = #{url}\n"
        next
      end

      homesite = get_home_site(url.to_s)
      level = articles[art]

      print "Processing #{url} (#{homesite}) at level #{level}\n"

      if (level <= @@recursion_level)
      
        links = get_all_hrefs_nokogiri(url)
        
        # look at each of the links on this page and search for possible rss feed links
        links.keys.each do |k|
            # if it is a feed link, append to list
            if ((k =~ /(rss|atom|feed|subscribe)/i) && (links[k].to_s =~ /\w/))
              new_feeds << links[k]
              print "  Found new feed link: #{links[k]} #{$1}\n"
            end
            
            # if it is an outside link, add to list of other sites
            link_home = get_home_site(links[k].to_s)
            if ((link_home.length>0) && !(homesite == link_home)) # TBD also check that we haven't visited the site
              #print " ==== #{homesite} not same as #{link_home}\n"
              new_links[Article.create(:url=>links[k])] = level + 1
            end
        
        end
        
        # look at each link and see what other sites it might possible point to
        #  if it goes outside this site, then append it to the array
 
      end
    end

    return new_feeds.size + find_feeds_recursive(new_links)

  end
  
  def get_articles_to_crawl
    # return list of articles that we should check for feed links
    hash = {}
    Article.find(:all, :limit => 5).map{|a| hash[a] = 0}  # this is not optimal but good enough for a first cut

    # hash : key is the article url, value is the recursion level
    #return hash
    return { Article.create( :url => 'http://fifthdown.blogs.nytimes.com/'), 0}
    end

  def get_all_hrefs_nokogiri (url)
    begin
      doc = Nokogiri::HTML(open(url))
      links = doc.css('a')
      
      h = {}
      links.map {|link| h[link.inner_text] = link.attribute('href')}
      #hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
      #hrefs = links.map {|link| link.inner_text.to_s}.uniq.sort.delete_if {|href| href.empty?}
      #return hrefs
      #return links[0]
      return h
    rescue
      return {}
    end
  end

  def get_home_site(url)
    if (url =~ /^http:\/\//)
      url = url.gsub(/^http:\/\//i, '' )
    else
      #print "not http\n"
      return ''
    end

    l1 = ''
    l2 = ''
    if (url =~ /(.*?)\//)
      domain = $1
      domain.each('.') { |t| l2 = l1; l1 = t.gsub(/\./, '') }
    elsif (url =~ /(.*\..*)/)
      url.each('.') { |t| l2 = l1; l1 = t.gsub(/\./, '') }
    else
      print "unrecognized url #{url}\n"
    end

    home_site = "#{l2}.#{l1}"
    #print "home is #{home_site}\n"

    return home_site

  end

  def test 
    links = get_all_hrefs_nokogiri('http://fifthdown.blogs.nytimes.com/')

    links.keys.each do |k|
      if (k =~ /(rss|atom|subscribe|feed)/i)
        print "#{k} => #{links[k]}\n"
      end
    end
  end

  def test2
    h = { 'a' => 100, 'b' => 200, 'c' => 300 }

    h.keys.each do |k|
      v = h[k]
      if (v == 100)
        h['d'] = 500
        print "appended\n"
      end
      print "#{k} and #{v}\n"
    end
  end

end
