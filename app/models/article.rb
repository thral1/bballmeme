class Article < ActiveRecord::Base
  has_many :links
 #validates_uniqueness_of :url
  #validates_uniqueness_of :title, :case_sensitive => false
  require 'nokogiri'
  require 'open-uri'

  #typedef struct {
    #string url;
    #text text;
  # text title;
  # text rss_description;
    #int number_visitors_per_month;// (use compete.com API @ http://developer.compete.com/, alternatively http://aws.amazon.com/awis/#details)
    #int site_ranking;// (use compete.com API @ http://developer.compete.com/, alternatively http://aws.amazon.com/awis/#details)
    ###int num_forward_links; // Use technorati API @ http://technorati.com/developers/api/cosmos.html or http://delicious.com/help/api (digg API, ballhype.com, truehoop.com, http://www.urltrends.com/viewtrend.php?url=http%3A%2F%2Fwww.espn.go.com, etc.)
    #int length_of_article;
    #int date_of_publication; //Use reddit or news.yc's algo: http://news.ycombinator.com/item?id=231168
    #enum rss_feed_level; //come up with a 3-level system pp
    ###list teams_mentioned; //union of the teams mentioned in the article
    ###list players_mentioned; //union of the teams mentioned in the article
    ###string author;
    ###int num_comments;
    #string publication_name;
    #int user_vote_score;
    #string writer_score; //INTERNAL score for writer popularity
    #int publication_score; //INTERNAL score for site popularity
    #} article;
  #player mentioned
#-maybe we can come up with a metric to define the "uniqueness" of each article.  We can calculate "distance" between articles so that our site features a diverse subject matter.
#number of hits (off our website)

  @@COMPETE_KEY = "&apikey=7xja2naxw7kh4amchsw93qa6"
  @@COMPETE_URL = "http://api.compete.com/fast-cgi/MI?d="
  #@compete_domain_name_id = "d="
  @@COMPETE_VERSION = "&ver=3"
  @@COMPETE_SIZE = "&size=large"

  #jlk
  #Eventually add state so you keep track of comment IDs.  When comparing comment IDs, only compare *consecutive* ones.  
  #do the doc ||= thing here so you don't reopen the same thing twice
  #Use a tmp variable for num_comments, so that in get_number_of_comments() we can have a single return point
  #Eventually we have to parse by HTML elements, and not by line, because some articles write really bad HTML that will kill our performance.
  def get_number_of_comments_generic( url, doc = nil )
    RUFUS_LOG.info "get_number_of_comments_generic()\n"
    if( doc.nil? )
      doc = Nokogiri::HTML( open( url ) )
    end
    self[:num_comments] = 0
    previous_comment_id = -1
    doc.to_html.each_line {|s| 
                            #See if the article tallies up all the comments and prints tally on the page
                            if( s =~ /<h3 id.*=.*comments\D*(\d+).*Responses/i )
                              self[:num_comments] = $1.to_i
                              RUFUS_LOG.info "case 1, number of comments: #{s}\n"
                              break
                            end

                            if( s =~ /<.*h\d+.*>.*?(\d+) (Comments|Responses)/i )
                              self[:num_comments] = $1.to_i
                              RUFUS_LOG.info "case 2, number of comments: #{s}\n"
                              break
                            end

                            if( s =~ /<h\d+>(\d+).*comments.*post-comment.*/i )
                              self[:num_comments] = $1.to_i
                              RUFUS_LOG.info "case 3, number of comments: #{s}\n"
                              break
                            end
                            
                            #<p>There are 8 responses. <a href="#respond">Respond</a>.</p>
                            if( s =~ /<.*?p.*?>There are (\d+) (responses|comments).*?(respond|comment)/i )
                              self[:num_comments] = $1.to_i
                              RUFUS_LOG.info "case 4, number of comments: #{s}\n"
                              break
                            end

						                #<div class="gc_teasers_label">Comments (43)</div>
                            if( s =~ /Comments \((\d+)\)/ )
                              self[:num_comments] = $1.to_i
                              RUFUS_LOG.info "case 5, number of comments: #{s}\n"
                              break
                            end

                            #Can't get comments in a single line, so count them one-by-one
                            if( s =~ /comment/i )
                              if( s =~ /<(div|li).*(id|class).*=.*("|')comment.*?(\d+).*(class|id).*=.*("|')/ )
                                if( $4 != previous_comment_id )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 1, got a comment: #{s}\n"
                                  puts "type 1, got a comment: #{s}\n"
                                else
                                  RUFUS_LOG.info "type 1, but skip cuz we saw this comment id before: #{$4}\n"
                                  puts "type 1, but skip cuz we saw this comment id before: #{$4}\n"
                                end
                                previous_comment_id = $4
=begin
                              elsif( s =~ /<(div|li).*id.*=.*("|')comment-(\w+)(-content)*("|')/ )
                                if( $3 != previous_comment_id )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 2.5, got a comment: #{s}\n"
                                  puts "type 2.5, got a comment: #{s}\n"
                                else
                                  RUFUS_LOG.info "type 2.5, but skip cuz we saw this comment id before: #{s}\n"
                                  puts "type 2.5, but skip cuz we saw this comment id before: #{s}\n"
                                end
                                previous_comment_id = $3
=end
      #<div id="comment_body_19474108" class="cbody">
                              elsif( s =~ /<(div|dd|p|li) (class|id).*?=.*?("|')(onecomment|comment-body|comment_body|message|comment-content).*?("|')/i )
                                self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 3, got a comment: #{s}\n"
                                  puts "type 3, got a comment: #{s}\n"
=begin
                                if( $4 != previous_comment_id )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 6, got a comment: #{s}\n"
                                  puts "type 6, got a comment: #{s}\n"
                                else
                                  RUFUS_LOG.info "type 6, but skip cuz we got this comment id before: #{s}\n"
                                  puts "type 6, but skip cuz we got this comment id before: #{s}\n"
                                  previous_comment_id = $4
                                end
=end
=begin
                              elsif( s =~ /<.*?a .*?name.*?=.*?("|')comment-(\d+).*? id.*?=.*?("|')comment-\d+/i )
                                if( $2 != previous_comment_id )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 4, got a comment: #{s}\n"
                                else
                                  RUFUS_LOG.info "type 4, but skip cuz we saw this comment id before: #{s}\n"
                                end
                                previous_comment_id = $2
                              elsif( s =~ /<div class.*?=.*?("|')(one)*comment("|')/i )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 6, got a comment: #{s}\n"
                              elsif( s =~ /<(dd|p).*?class.*?=.*?("|')(comment-body|message)("|')/i )
                                if( s =~ /comment-(\d+)/i )
                                  if( $1 != previous_comment_id )
                                    self[:num_comments] = self[:num_comments] + 1
                                    RUFUS_LOG.info "type 7, got a comment: #{s}\n"
                                  else
                                    RUFUS_LOG.info "type 7, but skip cuz we saw this comment id before: #{s}\n"
                                  end
                                  previous_comment_id = $1
                                else
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 7, got a comment: #{s}\n"
                                end
=end
                              end
                            end
                          }
    RUFUS_LOG.info "Number of comments for #{url.to_s}: #{self[:num_comments]}"
    puts "Number of comments for #{url.to_s}: #{self[:num_comments]}"
  end

  def get_number_of_comments( url, doc = nil)
    RUFUS_LOG.info "get_number_of_comments(): #{url}\n"
    if( doc.nil? )
      doc = Nokogiri::HTML( open( url ) )
    end
    self[:num_comments] = 0

    if( url.to_s =~ /espn.go.com\/blogs\/truehoop/ )
        RUFUS_LOG.info "truehoop article"

      if( doc.to_html =~ /conversation_content_id = '(.*)\'/)#'/ )
        #conversation_content_id = 'truehoop-blog-0-38-329';
        RUFUS_LOG.info "Truehoop article ID: #{$1}"
        espn_conversation_url = "http://mb.espn.go.com/dir-app/acx/activeContent.aspx?catList=Conversations&webtag=espnmb&fmt=json&type=talkback&contentID=#{$1}&timeout=1&count=50&leaveHtml=true"#&scriptkey=_conversation&ÿƿÿ¸newestFirst=true&callbackParam=local&callback=?\""
        #espn_conversation_url = "http://mb.espn.go.com/dir-app/acx/activeContent.aspx?catList=Conversations&webtag=espnmb&fmt=json&type=talkback&contentID=#{$1}&timeout=1&count=50&leaveHtml=true&scriptkey=_conversation&ÿƿÿ¸newestFirst=true&callbackParam=local&callback=?\",function(json){var stuff_we_want,i,tot,plural,allcomments"
        espn_convo_doc = Nokogiri::HTML(open( espn_conversation_url ))
        if( espn_convo_doc.to_html =~ /messageCount\":(\d+)/ )
          RUFUS_LOG.info "Truehoop article has #{$1} comments"
  self[:num_comments] = $1.to_i
        else
          RUFUS_LOG.info "Truehoop article has no comments"
        end
      else
        RUFUS_LOG.info "Truehoop article can't find ID"
      end

    elsif( url.to_s =~ /espn.go.com/ )
        RUFUS_LOG.info "espn article"

      if( doc.to_html =~ /go.com\/conversation\/story\?id=(\d+)/ )
        RUFUS_LOG.info "ESPN article ID: #{$1}"
        espn_conversation_url = "http://mb.espn.go.com/dir-app/acx/activeContent.aspx?catList=Conversations&webtag=espnmb&fmt=json&type=talkback&contentID=#{$1}&timeout=1&count=50&leaveHtml=true"#&scriptkey=_conversation&ÿƿÿ¸newestFirst=true&callbackParam=local&callback=?\""
        #espn_conversation_url = "http://mb.espn.go.com/dir-app/acx/activeContent.aspx?catList=Conversations&webtag=espnmb&fmt=json&type=talkback&contentID=#{$1}&timeout=1&count=50&leaveHtml=true&scriptkey=_conversation&ÿƿÿ¸newestFirst=true&callbackParam=local&callback=?\",function(json){var stuff_we_want,i,tot,plural,allcomments"
        RUFUS_LOG.info "convo URL: #{espn_conversation_url}"
        espn_convo_doc = Nokogiri::HTML(open( espn_conversation_url ))
        if( espn_convo_doc.to_html =~ /messageCount\":(\d*)/ )
          RUFUS_LOG.info "ESPN article has #{$1} comments"
  self[:num_comments] = $1.to_i
        else
          RUFUS_LOG.info "ESPN article has no comments"
        end
      else
        RUFUS_LOG.info "No comments found for article: #{url.to_s}"
        #RUFUS_LOG.info "html: #{doc.to_html}"
      end

    elsif( doc.to_html =~ /meta.*name.*generator.*content.*Blogger/i ||
           doc.to_html =~ /meta.*content.*blogger.*name.*generator/i ) #<meta name="generator" content="Blogger" />
      RUFUS_LOG.info "blogger article"
      doc.to_html.each_line {|s| 
                              #<p class="comment-body">
                              if( s =~ /(dd|p).*class.*=.*comment-body/i )
                                self[:num_comments] = self[:num_comments] + 1
                                #RUFUS_LOG.info "COMMENT!: #{s}\n"
                              end
                            }
    elsif( doc.to_html =~ /meta.*name.*generator.*content.*typepad/i ) #<meta name="generator" content="http://www.typepad.com/" />
      RUFUS_LOG.info "Typepad article"
      doc.to_html.each_line {|s| 
                              #todo: This only gets the comments on the 1st page.  Need to get subsequent pages of comments ! (jlk)
                              #line 1: 			<div class="comment-content" id="comment-6a00d8341c2c7653ef01157070ba6c970b-content">
                              if( s =~ /div.*class.*=.*comment-content/i &&
                                  !(s =~ /div.*class.*=.*\\"comment-content/i) )
                                self[:num_comments] = self[:num_comments] + 1
                                #RUFUS_LOG.info "COMMENT!: #{s}\n"
                              end
                            }
    elsif( doc.to_html =~ /meta.*name.*generator.*content.*WordPress/i ) #<meta name="generator" content="WordPress 2.8.2" />
        RUFUS_LOG.info "Wordpress article"
      if( url.to_s =~ /nytimes\.com/ )
        doc.to_html.each_line{|s|
                                if( s =~ /<.*h4.*>.*?(\d+) Comment/i )
                                  self[:num_comments] = $1.to_i
                                  #RUFUS_LOG.info "COMMENT!: #{s}\n"
                                end
                              }
      else
        doc.to_html.each_line {|s| 
                                #line 1: 	<li class="comment-odd" id="comment-3764">
                                #line 2: <div id="div-comment-14336" class="comment-body">
                                #line 3: 		<li class="alt" id="comment-20">
                                if( s =~ /<h3 id.*=.*comments\D*(\d+).*Responses/i )
                                  self[:num_comments] = $1.to_i
                                  #RUFUS_LOG.info "COMMENT!: #{s}\n"
                                  break
                                end

                                if( s =~ /li.*class.*=.*("|')comment.*odd.*id.*=.*("|')comment/ )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 1, got a comment: #{s}\n"
                                elsif( s =~ /li.*class.*=.*("|')comment.*even.*id.*=.*("|')comment/ )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 2, got a comment: #{s}\n"
                                #s =~ /div.*id.*=.*div-comment-\d+.*class.*=.*comment-body/i || s =~ /div.*class.*=.*comment-body.*id.*=.*div-comment-\d+/i ||
                                elsif( s =~ /(div|li).*id.*=.*("|')comment-\d+/ )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 3, got a comment: #{s}\n"
                                elsif( s =~ /<.*?a .*?name.*?=.*?("|')comment-\d+.*? id.*?=.*?("|')comment-\d+/i )
                                  self[:num_comments] = self[:num_comments] + 1
                                  RUFUS_LOG.info "type 4, got a comment: #{s}\n"
                                end
                              }
      end
    elsif( url.to_s =~ /sltrib\.com/ )
      RUFUS_LOG.info "sltrib article"
      doc.to_html.each_line{|s|
                              if( s =~ /<.*h3.*>.*?(\d+) Comments/i )
                                self[:num_comments] = $1
                                #RUFUS_LOG.info "COMMENT!: #{s}\n"
                              end
      }
    elsif( url.to_s =~ /seattlepi\.com/ )
      RUFUS_LOG.info "seattlepi article"
      doc.to_html.each_line {|s| 
                              #<div class="message"><div class="onecomment"><div class="num"><b><a name=268226></a>#268226</b></div><p class="poster">Posted by
                              if( s =~ /div.*class.*=.*message/i )
                                self[:num_comments] = self[:num_comments] + 1
                                #RUFUS_LOG.info "COMMENT!: #{s}\n"
                              end
                            }
=begin
    elsif( url.to_s =~ /washingtonpost\.com/ )
      RUFUS_LOG.info "wapo article"
      doc.to_html.each_line {|s| 
			                        #<div class="commentText">
                              if( s =~ /div.*class.*=.*commentText/i )
                                self[:num_comments] = self[:num_comments] + 1
                                #RUFUS_LOG.info "COMMENT!: #{s}\n"
                              end
                            }
=end

    elsif( doc.to_html =~ /meta.*name.*generator.*content.*Joomla/i ) #  <meta name="generator" content="Joomla! 1.5 - Open Source Content Management" />
        RUFUS_LOG.info "Joomla article"
        doc.to_html.each_line {|s|
                                if( s =~ /<.*div.*class.*=.*comment-body/i )
                                  self[:num_comments] = self[:num_comments] + 1
                                  #RUFUS_LOG.info "COMMENT!: #{s}\n"
                                end
        }
    elsif( url.to_s =~ /cbssports\.com/ )
      RUFUS_LOG.info "CBS Sports article"
      doc.to_html.each_line{|s|
                              if( s =~ /(www\.cbssports\.com\/mcc\/messages\/board\/\d+).*View.*All.*Threads/i )
                                RUFUS_LOG.info "CBS sports msg board: #{$1}\n"
                                msg_board_doc = Nokogiri::HTML(open( "http://#{$1}" ))
                                msg_board_doc.to_html.each_line{|line|
                                  if( line =~ /Subject.*Started by.*Last Post/i )
                                    lines = line.split("</tr>")
                                    lines.each{|li|
                                      #<td align=\"right\">1</td>
                                      if( li =~ /<td *align=.?right.?>(\d+)/i )
                                        self[:num_comments] = self[:num_comments] + $1.to_i + 1 # (replies don't include original comment, so add it also)
                                    #    RUFUS_LOG.info("comments on this line: #{$1}\n")
                                      end
                                    }
                                    #RUFUS_LOG.info("lines.size: #{lines.size} lines.inspect: #{lines.inspect}")
                                  end
                                }
                              end
                              #if( s =~ /a.*href.*Reply to this thread .*(\d+) repl.*/i )
                              #  if( !$1.nil? )
                              #    self[:num_comments] = self[:num_comments] + $1.to_i + 1 # (replies don't include original comment, so add it also)
                              #  end
                              #    RUFUS_LOG.info "COMMENT!: #{s}\n"
#                              elsif( s =~ /<.*a.*href.*>.*Reply to this thread/i )
                              #elsif( s =~ /a.*href.*Reply to this thread/i )
                              #  self[:num_comments] = self[:num_comments] + 1
                              #    RUFUS_LOG.info "COMMENT!: #{s}\n"
                              #end
      }
    elsif( doc.to_html =~ /Copyright.*20\d+.*Sportsblogs/ )
      RUFUS_LOG.info "Sportsblogs article"
      doc.to_html.each_line{|s|
        if( s =~ /div.*id.*comment_body_\d+/i )
          self[:num_comments] = self[:num_comments] + 1
          #RUFUS_LOG.info "COMMENT!: #{s}\n"
        elsif( s =~ /comment_body/i )
          #RUFUS_LOG.info "no COMMENT!: #{s}\n"
        end
      }
    elsif( url.to_s =~ /hornets247\.com/ )
      RUFUS_LOG.info "hornets247 article"
    								#<h2>4 articulate comments <span class="h-link"><a href="#post-comment">post your own</a></span></h2>
      doc.to_html.each_line{|s|
        if( s =~ /<h2>(\d+).*comments.*post-comment.*/i )
          self[:num_comments] = $1.to_i
          #RUFUS_LOG.info "COMMENT!: #{s}\n"
        end
      }
    elsif( url.to_s =~ /foxsports\.com/ )
      RUFUS_LOG.info "foxsports article"
        #http://msn.foxsports.com/fe/js/site_wide.js.  This has the JS for comment calculating stuff
      doc.to_html.each_line{|s|
        #startComments("StoryComments",'9902688');  // load up story comments
        if( s =~ /startComments\D*(\d+)/i )
          commentsURL = "http://msn.foxsports.com/widget/comments?contentId=#{$1}&forumKey=StoryComments"
          RUFUS_LOG.info "commentsURL: #{commentsURL}"
          commentsPage = Nokogiri::HTML(open( commentsURL ))
          if( commentsPage.to_html =~ /itemsCount\D*(\d+)/i )
            RUFUS_LOG.info "found comments"
            self[:num_comments] = $1.to_i
          else
            RUFUS_LOG.info "no found comments"
          end
        end
      }
    elsif( url.to_s =~ /nydailynews\.com/ )
      RUFUS_LOG.info "nydailynews article"
      doc.to_html.each_line{|s|
			  #<script language="JavaScript" type="text/javascript" src="/forums/communityjs/44?forum=9&amp;key=5f6b593dab0d27d5e05517d5e82a3f39"></script>
        if( s =~ /\/forums\/communityjs\/(\d+)\?forum=(\d+)&amp;key=(\w+)"/i )
          forumURL = "http://www.nydailynews.com/forums/communityjs/#{$1}?forum=#{$2}&key=#{$3}"
          RUFUS_LOG.info "Found forums URL: #{forumURL}\n"
          forumPage = Nokogiri::HTML(open( forumURL ))
          forumPage.to_html.each_line{|line|
            #<a href=\"http://www.nydailynews.com/forums/thread.jspa?threadID=68043\" class=\"commentCount\" >3 comments</a>
            #if( line =~ /forums\/thread.jspa\?threadID=.*commentCount\D+(\d+).*comments/i ) -- this is deprecated apparently
            #<a href=\"http://www.nydailynews.com/forums/thread.jspa?threadID=68043\">See All Comments &raquo; </a>\n\t\t\t\t</div>\n\t\t\t\t<script type=\"text/javascript\">var forumMsgCount = 4;</script>
            if( line =~ /forumMsgCount.*?=.*?(\d+)/i )
              self[:num_comments] = $1.to_i
              break
            else
              #RUFUS_LOG.info "no comments on this line of forum page"
            end
          }
        elsif( s =~ /communityjs/i || s =~ /cleafix/i || s =~ /jive/i || s=~/forums/ || s =~ /JavaScript/ )
          #RUFUS_LOG.info "no match: #{s}\n"
        end
      }
    elsif( url.to_s =~ /greenbaypressgazette\.com/ )
      doc.to_html.each_line{|s|
#<script>	GEL.thepage.pageinfo.sn.pluck.commentCount = '1';</script><li class='comments'><span class='commenticon'></span> 	<span class='gslArticleControlsByLine' id='gslCtl-
        if( s =~ /commentCount.*?('|")(\d+)/i )
          RUFUS_LOG.info "found comments"
          self[:num_comments] = $2.to_i
        else
          #//RUFUS_LOG.info "no found comments"
        end
      }
    elsif( url.to_s =~ /sacbee\.com/ )
      doc.to_html.each_line{|s|
	#<div id="story_activity_count"><a href="#Comments_Container"><span class="icon icon-comment"></span>Comments</a> (<span id="commentsCount">0</span>) 
        if( s =~ /commentsCount.*?('|")(\d+)/i )
          RUFUS_LOG.info "found comments"
          self[:num_comments] = $2.to_i
        else
          #//RUFUS_LOG.info "no found comments"
        end
      }
    elsif( url.to_s =~ /sportingnews\.com/ )
      doc.to_html.each_line{|s|
        #  <h3 class="comments-title">Comments <span class="comment-count">(0)</span></h3>
        if( s =~ /class.*?=.*?('|")comment-count("|').*?\((\d+)\)/i )
          RUFUS_LOG.info "found comments"
          self[:num_comments] = $3.to_i
        else
          #//RUFUS_LOG.info "no found comments"
        end
      }
    elsif( url.to_s =~ /startribune\.com/ )
      doc.to_html.each_line{|s|
        #														<a href="http://comments.startribune.com/comments.php?d=asset_comments&amp;asset_id=76594162&amp;section=/sports/vikings">Read all 2 comments</a>&nbsp;&nbsp;|&nbsp;&nbsp;
        if( s =~ /asset_comments.*?Read all (\d+) comment/i )
          RUFUS_LOG.info "found comments"
          self[:num_comments] = $1.to_i
        else
          #//RUFUS_LOG.info "no found comments"
        end
      }
    elsif( url.to_s =~ /yahoo\.com/ )
      doc.to_html.each_line{|s|
        #      <h4><span>37</span> Comments</h4>
        if( s =~ /h4.*?<span>.*?(\d+).*?<\/span>.*?Comment/i )
          RUFUS_LOG.info "found comments"
          self[:num_comments] = $1.to_i
        else
          #//RUFUS_LOG.info "no found comments"
        end
      }
    elsif( url.to_s =~ /bleacherreport\.com/ )
      doc.to_html.each_line{|s|
        #"comments_count":26
        if( s =~ /comments_count("|').*?:(\d+)/i )
          RUFUS_LOG.info "found comments"
          self[:num_comments] = $2.to_i
        else
          #//RUFUS_LOG.info "no found comments"
        end
      }
    elsif( url.to_s =~ /denverpost\.com.*?ci_(\d+)/ )
          forumURL = "http://neighbors.denverpost.com/viewtopic.php?t=#{$1}"
          RUFUS_LOG.info "Found forums URL: #{forumURL}\n"
          forumPage = Nokogiri::HTML(open( forumURL ))
          forumPage.to_html.each_line{|line|
            #494 posts			 &bull; <a href="#" onclick="jumpto(); return false;" title="Click to jump to page�">Page <strong>1</strong> of <strong>20</strong></a> &bull; <span><strong>1</strong><span class="page-sep">, </span><a href="./viewtopic.php?f=2&amp;t=13843976&amp;st=0&amp;sk=t&amp;sd=a&amp;sid=2681bea3760bfe983bcfabd1bbc0b74d&amp;start=25">2</a><span 
            if( line =~ /(\d+) posts.*?bull;.*?Click to jump/i )
              self[:num_comments] = $1.to_i
              break
            else
              #RUFUS_LOG.info "no comments on this line of forum page"
            end
          }
    elsif( url.to_s =~ /buffalonews\.com/ )
      RUFUS_LOG.info "buffalonews article"
      doc.to_html.each_line{|s|

        if( s =~ /account.mybuffalo.com\/comments\/\?storyId=(\d+)/i )
          forumURL = "http://account.mybuffalo.com/comments/?storyId=#{$1}"
          RUFUS_LOG.info "Found forums URL: #{forumURL}\n"
          forumPage = Nokogiri::HTML(open( forumURL ))
          forumPage.to_html.each_line{|line|
            #"commentCount":"1"
            if( line =~ /commentCount".*?("|')(\d+)("|')/i )
              self[:num_comments] = $1.to_i
              break
            else
              #RUFUS_LOG.info "no comments on this line of forum page"
            end
          }
        elsif( s =~ /account.mybuffalo.com/i )
          RUFUS_LOG.info "match str: #{s}\n"
        end
      }

    else
      RUFUS_LOG.info "No specific comment pattern for: #{url}, calling generic() parsing function"
      #get_number_of_comments_generic( url, doc )
    end

    RUFUS_LOG.info "Number of comments for #{url.to_s}: #{self[:num_comments]}"
    puts "Number of comments for #{url.to_s}: #{self[:num_comments]}"
  end

  def get_site_ranking( url )
    domain = ""
    compete_info_url = ""

    if ( url =~ /http:\/\/(.*)\.(com|info|net|org|me|mobi|us|biz)/i ) 
      domain = "#{$1}.#{$2}"
      RUFUS_LOG.info "URL string: #{domain}\n"
      RUFUS_LOG.info "#{@@COMPETE_URL}#{domain}#{@@COMPETE_VERSION}#{@@COMPETE_KEY}#{@@COMPETE_SIZE}"
      compete_info_url = "#{@@COMPETE_URL}#{domain}#{@@COMPETE_VERSION}#{@@COMPETE_KEY}#{@@COMPETE_SIZE}"
    else
      RUFUS_LOG.info "no match URL string: #{url}\n"
      compete_info_url = "#{@@COMPETE_URL}#{url}#{@@COMPETE_VERSION}#{@@COMPETE_KEY}#{@@COMPETE_SIZE}"
    end

    if ( urlinfo = Urlinfo.find_by_url( domain ) ) #url is in DB
      RUFUS_LOG.info "#{domain} already in Urlinfo db\n"
      self[:num_visitors_per_month] = urlinfo.num_monthly_visitors
      self[:site_ranking] = urlinfo.site_ranking
    else
      doc = open( compete_info_url ) do |f|
        Nokogiri::XML(f)
      end

      #RUFUS_LOG.info "doc: #{doc.inspect}"
      (doc/:ci).each do |item|
        self[:num_visitors_per_month] = (item/:count).inner_html.gsub( /,/, "" ).to_i
        self[:site_ranking] = (item/:ranking).inner_html.gsub( /,/, "" ).to_i

        RUFUS_LOG.info "num_monthly_visitors: #{num_visitors_per_month}"
        RUFUS_LOG.info "site ranking: #{site_ranking}\n"
      end

      urlinfo = Urlinfo.create( :url => domain, 
                                :num_monthly_visitors => self[:num_visitors_per_month], 
                                :site_ranking => self[:site_ranking] )
      if( !urlinfo )
        RUFUS_LOG.error "Insert into Urlinfo table failed: #{domain}\n"
      end
    end
  end

  def fill_publication_name
    if( self[:url] =~ /http:\/\/(.*?)\// )
      self[:publication] = $1
    else
      self[:publication] = self[:publication_name]
    end
  end

  def format_author
      #doc = Nokogiri::HTML( self[:author] )
      #self[:author] = doc.inner_text
      if self[:author] =~/^\s(B|b)(Y|y)\s(.*)/
        self[:author] = $3
      end

  end

  def parse_title
    if( self[:title] =~ /open thread/i ||
        self[:title] =~ /gamethread/i ||
        self[:title] =~ /game thread/i ||
        self[:title] =~ /thread #\d+/i ||
        self[:title] =~ /draft thread/i ||
        self[:title] =~ /discussion thread/i ||
        self[:title] =~ /press conference thread/i ||
        self[:title] =~ /live thread/i ||
        self[:title] =~ /first quarter thread/i ||
        self[:title] =~ /second quarter thread/i ||
        self[:title] =~ /third quarter thread/i ||
        self[:title] =~ /fourth quarter thread/i ||
        self[:title] =~ /first half thread/i ||
        self[:title] =~ /first-half thread/i ||
        self[:title] =~ /1st half thread/i ||
        self[:title] =~ /second half thread/i ||
        self[:title] =~ /second-half thread/i ||
        self[:title] =~ /2nd half thread/i ||
        self[:title] =~ /Pregame Primer/i ||
        self[:title] =~ /Game \d+ Preview/i ||
        self[:title] =~ /game chat/i ||
        self[:title] =~ /Watch live/i ||
        self[:title] =~ /live stream/i ||
        self[:title] =~ /live game blog/i ||
        self[:title] =~ /gameday thread/i 
      )
      self[:hide] = 1
    else
      self[:hide] = 0
    end

  end

  def evaluate_article( url = nil )
    self[:text] = ''

    if !url.nil?
      self[:url] = url #JLK Remove
    else
      url = self[:url]
    end
    RUFUS_LOG.error "evaluate_article( #{url} )\n"

    doc = nil

    begin
      puts "opening: #{url}\n"
      RUFUS_LOG.error "opening: #{url}\n"
      f = open( url )
      doc = Nokogiri::HTML( f )
      puts "done opening: #{url}\n"
      RUFUS_LOG.error "done opening: #{url}\n"

    fill_publication_name

    parse_title

    format_author

    RUFUS_LOG.info "parse_text( #{url} )\n"
    parse_text( doc )

    RUFUS_LOG.info "get_site_ranking: #{url}\n"
    get_site_ranking( url )

    get_number_of_comments( url, doc )

    get_article_length

    save!
    rescue Exception => e
      RUFUS_LOG.error "exception in #{url} in evaluate_article()"
      RUFUS_LOG.error "Exception: #{e.backtrace.join("\n")}: (#{$!})"
      puts "exception in #{url} in evaluate_article()"
      save
      return -1
    end
   return true 
=begin
    if save
      RUFUS_LOG.error "teams mentioned: #{self[:teams_mentioned]}"
      RUFUS_LOG.error "save succeeded id: #{inspect}"
      puts "save succeeded id: #{inspect}"
      return true
    else
      RUFUS_LOG.error "Save failed! #{inspect}\n"
      return -1
    end
=end
  end

  def calculate_inbound_links
    self.num_backward_links = Link.find_all_by_url( self[:url] ).size

    if !save
      RUFUS_LOG.info "Save failed: #{inspect}\n"
    end

    return self.num_backward_links
  end

  def calculate_outbound_links( div )
    
    #Use a hash so we don't count multiple links to another article more than once
    h = Hash.new

    div.css("a").each {|a|
        h[a.get_attribute("href")] = 1
    }

    h.each {|url,count| 
        unless self[:url] == url
          # automatically saves link, and creates association in the article table
          links << Link.new( :url => url, :article_id => self.id )
        end
    }
  end
  
  def get_article_length
    if( !self[:text].nil? )
      self[:length] = text.length
    else
      self[:length] = 0
    end
  end

  def getCharCount( e, s = "," )
    if e.nil? 
      return 0
    end

    return e.to_html.split(s).length
  end

  def getCharCount2( e, s = "," )
    if e.nil? 
      return 0
    end

    return e.to_html.split(s).length - 1
  end
  
  def cleanStyles( e )
    if e.nil?
      return 0
    end

    e.remove_attribute("style")

    e.children.each do |cur|
      if (cur.class.to_s =~ /Elem/)
        #RUFUS_LOG.info "Remove attribute: #{cur.class}\n"
        cur.remove_attribute("style")
        cleanStyles( cur )
      end
    end

    return e
  end

  def killDivs( e )
    if e.nil?
      return 0

    else
      @divsList = e.css("div")
      @curDivLength = @divsList.length

      #Gather counts for other typical elements embedded within.
      #Traverse backwards so we can remove nodes at the same time without effecting the traversal.
      #RUFUS_LOG.info "divslist.length: #{@divsList.length}"
      @divsList.each do |div|
        @p = div.css("p").length
        @img = div.css("img").length
        @li = div.css("li").length
        @a = div.css("a").length
        @embed = div.css("embed").length
        @commas = getCharCount( div, "'")
        @text_length = div.inner_text.length
        @ratio = @text_length / (@commas + 1)
        
        #If the number of commas is less than 10 (bad sign) ...
        #RUFUS_LOG.info "commas: #{@commas}"
        #RUFUS_LOG.info "words: #{div.inner_text.length}"
        if( @commas < 10 )
          #And the number of non-paragraph elements is more than paragraphs
          #or other ominous signs:
          if( ( @img > @p || @li > @p || @a > @p || @p == 0 || @embed > 0 ) &&
              !(div["class"].to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/) &&
              ( div.inner_text.length < 200 && @ratio > 125 )
            )
            #RUFUS_LOG.info "Deleting classes: #{div["class"].to_s} len: #{div.inner_text.length} commas: #{@commas} ratio: #{div.inner_text.length / (@commas + 1)} text: #{div.inner_text}"
            div.remove
            #RUFUS_LOG.info "Deleting... div.inspect: #{div.inspect}"
            #RUFUS_LOG.info "div.parent.inspect: #{div.parent.inspect}"
            #@divsList.delete(div)
          elsif( div["class"].to_s =~ /article-photo-wrapper|article_body_caption/ )
            div.remove
          elsif ( div.inner_text.length == 0 || 
                  ( div["class"].to_s =~ /comment|meta|footer|footnote|col/ && !(div["class"].to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/) ) ||
                  ( div.get_attribute("id").to_s =~ /comment|meta|footer|footnote|col/ && !(div.get_attribute("id").to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/) )
                )
            #RUFUS_LOG.info "Deleting classes: #{div["class"].to_s} len: #{div.inner_text.length} commas: #{@commas} ratio: #{div.inner_text.length / (@commas + 1)} text: #{div.inner_text}"
            div.remove
          else
            #RUFUS_LOG.info "Keeping classes: #{div["class"].to_s} len: #{div.inner_text.length} commas: #{@commas} ratio: #{div.inner_text.length / (@commas + 1)} text: #{div.inner_text}"

          end
        end
      end

      #RUFUS_LOG.info "e.get_elements_by_tag_name(\"div\").length: #{e.get_elements_by_tag_name("div").length}"
    end
    return e

  end

  def killBreaks( e )
    if e.nil? 
      return 0
    else
      e.inner_html = e.inner_html.gsub(/(<br\s*\/?>(\s|&nbsp;?)*){1,}/, "<br />")
      return e
    end
  end

  def clean( e, tags, minWords = 1000000 )
    if e.nil?
      return 0
    else
      targetList = e.css( tags )

      targetList.each do |target|
		  #If the text content isn't laden with words, remove the child:
        if( getCharCount(target, " ") < minWords )
          target.remove
        end
      end

      return e
    end
  end

  def parse_text( doc = nil)
    RUFUS_LOG.info "parse_text()\n"
    @topDiv = nil
    if( doc )
      @doc = doc
    else
      @doc = Nokogiri::HTML( open( url ) )
    end
    #RUFUS_LOG.info "parse_text(), #{@doc.search("//p").size} paragraphs\n"

    #myFile = File.new("pre.html", "w+")
    #url_string = url.split(/\W/) 
    #myFile = File.new("#{url_string}_pre.html", "w+")
    #myFile.write( @doc.to_html )
    #myFile.close

    #Replace all doubled-up <BR> tags with <p> tags, and remove fonts
    #@doc.inner_html = @doc.inner_html.gsub(/<br *\/?>[ \r\n\s]*<br *\/?>/, "</p><p>")
    #@doc.inner_html = @doc.inner_html.gsub(/(<br[^>]*>[ \n\r\t]*){2,}/, "</p><p>")
    #RUFUS_LOG.info "parse_text(), #{@doc.search("//p").size} paragraphs\n"
    #@doc.inner_html = @doc.inner_html.gsub(/<\/?font[^>]*>/, "")
    #RUFUS_LOG.info "parse_text(), #{@doc.search("//p").size} paragraphs\n"

    @allParagraphs = @doc.search("//p")

    if( !@allParagraphs.nil? )
      @allParagraphs.each do |p|
      #RUFUS_LOG.info "parse_text(), paragraph\n"

        #Look for a special classname
        if( p.parent.instance_variable_get(:@readability).nil? )
          #RUFUS_LOG.info "FIRST PARAGRAPH!!!!\n\n"
          p.parent.instance_variable_set(:@readability, 0)
          #RUFUS_LOG.info "p.parent.classes: #{p.parent["class"]}"
          if( p.parent["class"].to_s =~ /comment|meta|footer|footnote|col/ ||
              p["class"].to_s =~ /comment|meta|footer|footnote|col/ )
            #RUFUS_LOG.info "class matches: comment|meta|footer|footnote|col\n"
            p.parent.instance_variable_set(:@readability, p.parent.instance_variable_get(:@readability) - 50)
          #elsif( p.parent["class"].to_s =~ /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/)
          elsif( p.parent["class"].to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/ ||
                 p["class"].to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/ )
            #RUFUS_LOG.info "class matches: post|hentry|entry|content|text|body|article|blogEntry|blogHead"
            p.parent.instance_variable_set(:@readability, p.parent.instance_variable_get(:@readability) + 25)
          end

          #Look for a special ID
          #RUFUS_LOG.info "p.parent.attribute: #{p.parent.attribute("id")}\n"
          if( p.parent.attribute("id").to_s =~ /comment|meta|footer|footnote|col/ ||
              p.attribute("id").to_s =~ /comment|meta|footer|footnote|col/ )
            #RUFUS_LOG.info "attribute matches: comment|meta|footer|footnote|col"
            p.parent.instance_variable_set(:@readability, p.parent.instance_variable_get(:@readability) - 50)
          #elsif( p.parent.attribute("id").to_s =~ /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/)
          elsif( p.parent.attribute("id").to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/ ||
                 p.attribute("id").to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/ )
            #RUFUS_LOG.info "attribute matches: post|hentry|entry|content|text|body|article|blogEntry|blogHead"
            p.parent.instance_variable_set(:@readability, p.parent.instance_variable_get(:@readability) + 25)
          end
        else
          #RUFUS_LOG.info "NOT FIRST PARAGRAPH!!!\n\n"
        end

        #Add a point for the paragraph found
        if( p.inner_text.length > 10 )
          #RUFUS_LOG.info "inner_text > 10: #{p.inner_text.length}"
          p.parent.instance_variable_set(:@readability, p.parent.instance_variable_get(:@readability) + 1)
        else
          #RUFUS_LOG.info "inner_text < 10: #{p.inner_text.length}"
        end

        #Add points for any commas within this paragraph
        #RUFUS_LOG.info "readability score (before): #{p.parent.instance_variable_get(:@readability)}"
        #RUFUS_LOG.info "# of commas in paragraph: #{getCharCount( p, ",")}"
        p.parent.instance_variable_set(:@readability, p.parent.instance_variable_get(:@readability) + getCharCount( p, "," ))
        #RUFUS_LOG.info "readability score: #{p.parent.instance_variable_get(:@readability)}"
        #RUFUS_LOG.info "p.inner_html: #{p.inner_html}"
      end
    end

    #Assignment from index for performance. See http://www.peachpit.com/articles/article.aspx?p=31567&seqNum=5
    #    @styleTags = @doc.search("//*[@style]")

    divs = @doc.search("//div")
    if( !divs.nil? )
      divs.each do |e|
        if( e.instance_variable_get(:@readability).nil? )
          e.instance_variable_set(:@readability, 0)
          #RUFUS_LOG.info "e.classes (nil readability score): #{e["class"]}"
          #lightbox is from http://bleacherreport.com/articles/316274-jobbed-giants-steve-smith-left-off-pro-bowl-roster
          if( e["class"].to_s =~ /comment|meta|footer|footnote|col|lightbox_engage_content_bottom/ && (e.inner_text.length > 100) && (getCharCount( e, ",") > 5) )
            #RUFUS_LOG.info "class matches: comment|meta|footer|footnote|col\n"
            e.instance_variable_set(:@readability, e.instance_variable_get(:@readability) - 50)
          #elsif( e["class"].to_s =~ /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/)
          elsif( e["class"].to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/ && (e.inner_text.length > 100) && (getCharCount( e, ",") > 5) )
            #RUFUS_LOG.info "class matches: post|hentry|entry|content|text|body|article|blogEntry|blogHead"
            e.instance_variable_set(:@readability, e.instance_variable_get(:@readability) + 25)
          end

          #RUFUS_LOG.info "e.attribute: #{e.attribute("id")}\n"
          #RUFUS_LOG.info "e.attribute(id).to_s: #{e.attribute("id").to_s}\n"
          #RUFUS_LOG.info "e.inner_text.length: #{e.inner_text.length}\n"
          #RUFUS_LOG.info "e.to_html: #{e.to_html}\n"
          ##RUFUS_LOG.info "e.to_html.split: #{e.to_html.split(",")}\n"
          #RUFUS_LOG.info "getCharCount: #{getCharCount(e, ",")}\n"
          #Look for a special ID
          if( e.attribute("id").to_s =~ /comment|meta|footer|footnote|col|article-photo-wrapper/ && (e.inner_text.length > 100) && (getCharCount( e, ",") > 5) )
            #RUFUS_LOG.info "attribute matches: comment|meta|footer|footnote|col"
            e.instance_variable_set(:@readability, e.instance_variable_get(:@readability) - 50)
          #elsif( e.attribute("id").to_s =~ /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/)
          elsif( e.attribute("id").to_s =~ /post|hentry|entry|content|text|body|article|blogEntry|blogHead/ && (e.inner_text.length > 100) && (getCharCount( e, ",") > 5) )
            #RUFUS_LOG.info "attribute matches: post|hentry|entry|content|text|body|article|blogEntry|blogHead"
            e.instance_variable_set(:@readability, e.instance_variable_get(:@readability) + 25)
          end
          #RUFUS_LOG.info "readability score(modified): #{e.instance_variable_get(:@readability)}"
        else
          #RUFUS_LOG.info "e.classes.inspect (non-nil readability score): #{e.classes.inspect}"
          #RUFUS_LOG.info "e[\"class\"].to_s (non-nil readability score): #{e["class"].to_s}"
        end

        if( !e.instance_variable_get(:@readability).nil? && ( @topDiv.nil? || e.instance_variable_get(:@readability) > @topDiv.instance_variable_get(:@readability) ) )
          #RUFUS_LOG.info "candidate div: #{e.instance_variable_get(:@readability)}"
          #RUFUS_LOG.info "inner_text < 10: #{e.inner_text.length}"
          #RUFUS_LOG.info "# of commas in paragraph: #{getCharCount( e, ",")}"
          @topDiv = e
        end
        
        #RUFUS_LOG.info "readability score: #{e.instance_variable_get(:@readability)}\n\n"

        if (e && e.instance_variable_get(:@readability) && e.instance_variable_get(:@readability) > 0)
          #RUFUS_LOG.info "html: #{e.inner_html}"
        end
      end
    end

    #RUFUS_LOG.info "parse_text(), done parsing paragraphs and tags\n"
    if( @topDiv.nil? )
      RUFUS_LOG.info "Can't get article text for #{url}\n"
=begin
      @topDivs = Hpricot::Elements.new
      #@topDiv.insert_after
      @topDiv = @topDivs.first
      if( !@topDiv.nil? && !@topDiv.inner_html.nil? )
      @topDiv.inner_html = "Sorry, readability was unable to parse this page for content. If you feel like it should have been able to, please <a href=\"http://code.google.com/p/arc90labs-readability/issues/entry\">let us know by submitting an issue.</a>"
      end
=end
    end

    #Remove all stylesheets ??
    
    #RUFUS_LOG.info "parse_text(), remove style elems\n"
    #Remove all style tags in head
    #@styleTags = @doc.search("//*[@style]")
    @styleTags = @doc.css("style")
    @styleTags.each do |s|
      #RUFUS_LOG.info "attribute text (style) before was: #{s.get_attribute(text)}\n\n"
      #If not MSIE!!!!
      #RUFUS_LOG.info "s.get_attribute(text): #{s.get_attribute(text)}\n"
      if s.get_attribute(text)
        s.set_attribute(text, "") 
      end
    end

    #RUFUS_LOG.info "topDiv's html: #{@topDiv.inner_html}\n\n\n\n\n"
    
    #RUFUS_LOG.info "topDiv original inner_text: #{@topDiv.inner_text} inspect: #{@topDiv.inner_text.inspect}\n"
    cleanStyles(@topDiv) #Removes all styles attributes
    #RUFUS_LOG.info "length: #{@topDiv.css("div").length}\n"
    killDivs(@topDiv) #Goes in and removes DIV's that have more non <p> stuff than <p> stuff
    #RUFUS_LOG.info "length: #{@topDiv.css("div").length}\n"
    #RUFUS_LOG.info "after killdivs @topDiv: #{@topDiv.inner_text[0..50]}\n"
    #killBreaks(@topDiv) #Removes any consecutive <br />'s into just one <br />

    #Clean out junk from the topDiv just in case:
    #RUFUS_LOG.info "parse_text(), remove junk\n"
    clean( @topDiv, "form" )
    clean( @topDiv, "object" )
    clean( @topDiv, "table", 250 )
    clean( @topDiv, "h1" )
      #RUFUS_LOG.info "before h2 @topDiv: #{@topDiv.inner_text[0..50]}\n"
    clean( @topDiv, "h2" )
      #RUFUS_LOG.info "after h2 @topDiv: #{@topDiv.inner_text[0..50]}\n"
    clean( @topDiv, "iframe" )

    if @topDiv
      self[:text] = @topDiv.inner_text # save to text field
    #  RUFUS_LOG.info "@topDiv: #{@topDiv.inner_text}\n"
=begin
      f = File.new("article_text.html", "w")
      f.write( "Inner text: \n\n" )
      f.write( @topDiv.inner_text )
      f.write( "\n\n\n\n" )
      f.write( "Formatted text: " )
=end
      self[:text] = format_article( @topDiv )
      #self[:text] = format_text( @topDiv.inner_text )
=begin
      f.write( self[:text] )
      f.write( "\n\n\n\n" )
      f.write( "HTML: \n\n" )
      f.write( @topDiv.to_html )
      f.close
=end

      #This creates text files containing the parsed article text (for test purposes)
      #f = File.new("#{url}.nokogiri.text", "w")
      #f.write( self[:text] )

      RUFUS_LOG.error "check_for_teams_mentioned string: #{self[:text]} #{self[:title]}"
      check_for_teams_mentioned( "#{self[:text]} #{self[:title]}" )
      check_for_players_mentioned( self[:text] )
      calculate_outbound_links( @topDiv )
      RUFUS_LOG.info "teams mentioned: #{self[:teams_mentioned]}\n"
      @topDiv
    end

  #pattern = RegExp.new("<br/?>[ \r\n\s]*<br/?>", "g")
	# Replace all doubled-up <BR> tags with <P> tags, and remove fonts.
  #(doc/"/html/body") = (doc/"/html/body").gsub(pattern, "</p><p>").gsub(/<\/?font[^>]*>/g, "")

  #articleTitle.inner_html = 

    RUFUS_LOG.info "returning from parse_text()\n"
    return 0, self[:text]
  end

  #Remove an element from a node
  def remove_element( e, tag, class_id = // )
    elems = e.css( tag )
    elems.each {|e|
      if( e["class"].to_s =~ class_id || e["id"].to_s =~ class_id )
        e.remove
      end
    }
  end

=begin
-Get rid of: script, embed, span, h*
-p: byline, postinfo, datestamp, photo-description, premeta, date, headline
-div: storypoll, image-large, postMeta, postHeader, hype_buttons, date, headline, subhead, page-actions, imgcenter
-span: date, comments, blog_caption
-cite: source
-a: get rid of stuff within links
-strong:
-"photo by"
-h*: before p
=end
  def format_article ( e )
    RUFUS_LOG.info "format_article()\n"
    if e.nil?
      return 0
    else
      remove_element( e, "p", /byline|postinfo|datestamp|photo-description|premeta|date|headline|wp-caption-text|footer/ )
      remove_element( e, "div", /storypoll|image-large|postMeta|postHeader|hype_buttons|date|headline|subhead|page-actions|imgcenter|photo-tpl|photo-meta|sidebar/i )
      remove_element( e, "span", /date|comments|blog_caption/i )
      remove_element( e, "script" )
      remove_element( e, "embed" )
      remove_element( e, "cite" )
      remove_element( e, "style" )
      remove_element( e, "h1", /post-title|entry-title/i )
      remove_element( e, "h2", /post-title|entry-title/i )
      remove_element( e, "h3", /post-title|entry-title/i )
      remove_element( e, "h4", /post-title|entry-title/i )

      strongs = e.css("strong")
      strongs.each {|strong|
        #twomangame.com
        if( strong.inner_text =~ /Box Score|Play-by-Play|Shot Chart|GameFlow/i )
          #RUFUS_LOG.info "deleting strong: #{strong}\n"
          strong.remove
        end
      }
      bolds = e.css("b")
      bolds.each {|b|
        if( b.search("a").size > 0 )
          if( b.inner_text =~ /\|.*?Series Page/i )
            #RUFUS_LOG.info "This bold item has a link, delete it (espn article heading): #{b}\n"
            b.remove
          end
        end
      }

      self[:text] = format_text( e.inner_text )
    end
  end

  def format_text ( text )
    formatted_text = ""
    bGotFirstLine = false
    text.each_line {|s|

    s = s.gsub(/ /, "")#beasley article

      if( !bGotFirstLine )
        if( s =~ /\w+.*$/ )
          bGotFirstLine = true
          #RUFUS_LOG.info "valid words on this text line: #{s}\n"

          if( s =~ /^\s+(\w+)(.*)$/ )
            #RUFUS_LOG.info "string before: #{s}\n"
            s = "#{$1}#{$2}"
            #RUFUS_LOG.info "string after: #{s}\n"
          end
          
          s << "\n"

#skip the byline
          #if( s =~ /By (\w+) (\w+)\W*/i || s =~ /Leave a reply/i || s =~ /photo by/i )
          if( s =~ /^By (\w+) (\w+)\W*/i || s =~ /Leave a reply/i || s =~ /photo by/i )
            bGotFirstLine = false #false alarm, keep looking
            #add more cases of preamble patterns...
            #skip this preamble stuff
            #RUFUS_LOG.info "skip line: #{s}\n"
            s = ""
          end

        else
          #RUFUS_LOG.info "no words on this text line\n"
          s = ""
        end
      end

      formatted_text << "#{s}"
    }
    formatted_text
  end

end

