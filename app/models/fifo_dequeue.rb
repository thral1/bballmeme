class FifoDequeue
    require 'logger'
    require 'active_record'
    require 'sqlite3'
    rufus_logfile = File.open("/home/deviagaz/bballmeme/log/fifoDequeue.log", 'a')
    rufus_logfile.sync = true
    RUFUS_LOG = Logger.new(rufus_logfile)

    @@lock = 0


  def read_from_fifo_db
        begin
       Article.find_each(:conditions => "text is null", :batch_size=>1){ |a|
       #index = 0
       #as = Article.find(:all,:conditions => "teams_mentioned is null or teams_mentioned=''")
       #backward_as = as.sort{|a,b| b.id <=> a.id}
       #backward_as.each{ |a|
        # memory leak hack (see http://groups.google.com/group/god-rb/browse_thread/thread/1cca2b7c4a581c2/f0f040d41d7c49ea)
        begin
          x = 1
          #Article.find(id).evaluate_article
          #index = index + 1
          RUFUS_LOG.debug "evaluating article id: #{a.id} url:#{a.url}"
          #RUFUS_LOG.debug "evaluating article #{index} of #{as.size}"
          #p "evaluating article #{index} of #{as.size}"
          #RUFUS_LOG.debug "  feed name is #{a.publication_name}"
          a.evaluate_article
          GC.start
        rescue Exception => e
          RUFUS_LOG.error "Exception: #{e.backtrace.join("\n")}: (#{$!})"
          #RUFUS_LOG.error "Exception on evaluating article (#{$!})"

        ensure
        end
      }
      rescue Exception=>e
          RUFUS_LOG.error "Exception: #{e.backtrace.join("\n")}"
          RUFUS_LOG.error "Exception Article.find_each(#{$!})"
      ensure
      end
  end 


  def read_from_fifo_db_wrapper
    if @@lock==0
       @@lock = @@lock + 1
       read_from_fifo_db
       @@lock = @@lock - 1
     else
       RUFUS_LOG.debug "oops. task already running.  Lock: #{@@lock}"
    end        
  end

# deprecated stuff below here



  def self.lock
    @@lock
  end

  def read_from_fifo_wrapper
    if @@lock==0
       @@lock = @@lock + 1
       read_from_fifo
       @@lock = @@lock - 1
     else
       RUFUS_LOG.debug "oops. task already running.  Lock: #{@@lock}"
    end        
  end

  def read_from_fifo
    
    RUFUS_LOG.debug "start of read from fifo"

    # open the fifo text file which tells us which file to open and where to read from
    fifo = File.open("\/home\/deviagaz\/bballmeme\/perl\/fifo.txt", "r+")

    #fifo = File.open("perl\/fifo.txt", "r+")
    article_file = fifo.gets.chomp   # first line is the article file name
    pos = fifo.gets            # second line is the index
    fifo.close
    
    counter = 0
    left_off = 0;
    @lines = Array.new

    #article_file = "../" + article_file
    #article_file = "/home/deviagaz/bballmeme/" + article_file

    RUFUS_LOG.error "article_file: #{article_file}\n"

    RUFUS_LOG.debug "got file name #{article_file} and pos #{pos}"

    File.open(article_file, "r") do |file|
      file.seek(pos.to_i)           # go to where we left off

      url = String.new
      teams_associated = String.new
      date = String.new
      desc = String.new
      title = String.new
      author = String.new
      feed_name = String.new
      feed_level = 0
      while (line = file.gets)
          #puts "#{counter}: #{line}"
          #@lines << "#{counter}: #{line}";

          #RUFUS_LOG.debug "#{counter}: #{line}"
          if /\$VAR1 =/ =~ line
            if !url.empty?
              #flush what you have
              @lines << "link => #{url}"
              @lines << "title => #{title}"
              @lines << "feed_name => #{feed_name}"
              @lines << "date => #{date}"
              @lines << "desc => #{desc}"
              @lines << "author => #{author}"
              @lines << "feed_level => #{feed_level}"
              @lines << "================"

              begin
                a = Article.create( :url => url, 
                                    :title => title, 
                                    :publication_date => date, 
                                    :rss_feed_level => feed_level, 
                                    :rss_description => desc, 
                                    :author => author, 
                                    :publication_name => feed_name, 
                                    :article_rank => 0, 
                                    :score => 0,  
                                    :num_visitors_per_month => 0, 
                                    :num_backward_links => 0,
                                    :num_comments => 0,
                                    :teams_associated_with_url => teams_associated
                                  )

                if !a.id.nil?
                  RUFUS_LOG.debug "evaluating #{url}"
                  RUFUS_LOG.debug "  feed name is #{feed_name}"
                  a.evaluate_article(url)
         
                  RUFUS_LOG.debug "you are at #{file.pos}"
                else
                  RUFUS_LOG.debug "article.create failed for #{url}"
                end

                rescue Exception
                  RUFUS_LOG.error "Exception on creating/evaluating article at #{url} (#{$!})"
 
              ensure
                # increment counter 
                counter = counter + 1
              
                # clear out all states
                url = ''
                teams_associated = ''
                title = ''
                date = ''
                desc = ''
                author = ''
                feed_name = ''
                feed_level = 0

                # save where we left off
                #fifo = File.open("perl\/fifo.txt", "w")
                fifo = File.open("\/home\/deviagaz\/bballmeme\/perl\/fifo.txt", "w")
                fifo.puts article_file
                fifo.puts file.pos
                fifo.close
              end

            end 
          end 
	  
	  #RUFUS_LOG.debug "line is #{file.pos}"          

          if /\$VAR\d+ = 'link'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              url = $1 
            end
          elsif /\$VAR\d+ = 'teams_associated_with_this_url'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              teams_associated = $1 
            end
          elsif /\$VAR\d+ = 'date'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              date = $1 
            else
	            date = Date.today.to_s
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
              title = title.gsub(/\\\'/, "'");
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
          elsif /\$VAR\d+ = 'feed'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
	            feed_name = $1
            end
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

   RUFUS_LOG.debug "Done with fifo. Till next time..."
    
   #flash[:notice] = "POS: #{left_off}; #{counter} new article(s) since last refresh of this page "
    

    end
end


