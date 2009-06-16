class FifoDequeueWorker < BackgrounDRb::MetaWorker
  set_worker_name :fifo_dequeue_worker
#  reload_on_schedule true
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    add_periodic_timer(20) { read_from_fifo }
   # add_periodic_timer(10) { write_to_db }
    #add_timer(3) { read_from_fifo }
  end

  lock = 0
  def write_to_db
   logger.info "touching DB...\n"
   #Touch.find(1)
   touch = Touch.new
   touch.junktext = "blah"
   if touch.save
   else
    logger.info "save to DB failed!\n"
   end
  end

  def read_from_fifo_nop
    # no nothing
    logger.debug "nop"
  end

  def read_from_fifo_wrapper
    if lock==0
       lock = lock + 1
       read_from_fifo
       lock = lock - 1
     else
       logger.debug "oops. task already running"
    end        
  end

  def read_from_fifo
    
    logger.debug "start of read from fifo"

    # open the fifo text file which tells us which file to open and where to read from
    fifo = File.open("perl\/fifo.txt", "r+")
    article_file = fifo.gets.chomp   # first line is the article file name
    pos = fifo.gets            # second line is the index
    fifo.close
    
    counter = 0
    left_off = 0;
    @lines = Array.new

    logger.debug "got file name #{article_file} and pos #{pos}"

    File.open(article_file, "r") do |file|
      file.seek(pos.to_i)           # go to where we left off

      url = String.new
      date = String.new
      desc = String.new
      title = String.new
      author = String.new
      feed_name = String.new
      feed_level = 0
      while (line = file.gets)
          #puts "#{counter}: #{line}"
          #@lines << "#{counter}: #{line}";

          #logger.debug "#{counter}: #{line}"
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
				                            :num_comments => 0
	                                )
                logger.debug "evaluating #{url}"
                logger.debug "  feed name is #{feed_name}"
                a.evaluate_article(url)
       
		            logger.debug "you are at #{file.pos}"

              rescue Exception
	      	      logger.error "Exception on creating/evaluating article at #{url} (#{$!})"

              ensure
		# increment counter 
              	counter = counter + 1
              
                # clear out all states
                url = ''
                title = ''
                date = ''
                desc = ''
                author = ''
                feed_name = ''
                feed_level = 0

                # save where we left off
                fifo = File.open("perl\/fifo.txt", "w")
                fifo.puts article_file
                fifo.puts file.pos
                fifo.close
	      end

            end 
          end 
	  
	  #logger.debug "line is #{file.pos}"          

          if /\$VAR\d+ = 'link'/ =~ line
            if file.gets =~ /\$VAR\d+ = '(.*)';/
              url = $1 
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

   logger.debug "Done with fifo. Till next time..."
    
   #flash[:notice] = "POS: #{left_off}; #{counter} new article(s) since last refresh of this page "
    

    end
end

