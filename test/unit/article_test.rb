require 'test/test_helper'

class ArticleTest < ActiveSupport::TestCase
  fixtures :articles
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  def test_article_in_db
    article = Article.find(2)
    assert article
  end

  def test_num_comments_wordpress_generic
    article = Article.find(2)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 8 )
    puts "Article: #{article.inspect}\n"

    article = Article.find(5)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(6)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 16)
    puts "Article: #{article.inspect}\n"

    article = Article.find(7)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"
=begin
jlk - doesn't work yet
    article = Article.find(8)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 13)
    puts "Article: #{article.inspect}\n"
=end
    article = Article.find(10) #nytimes
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 73)
    puts "Article: #{article.inspect}\n"

    article = Article.find(11) #nytimes
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 21)
    puts "Article: #{article.inspect}\n"

=begin
jlk - this doesn't work right now
    article = Article.find(13)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 1)
    puts "Article: #{article.inspect}\n"
=end

    article = Article.find(17)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 14)
    puts "Article: #{article.inspect}\n"

=begin
jlk - this doesn't work right now
    article = Article.find(18)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 36)
    puts "Article: #{article.inspect}\n"
=end

    article = Article.find(19)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 23)
    puts "Article: #{article.inspect}\n"

=begin
jlk - this doesn't work right now
    article = Article.find(23)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(26)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 1)
    puts "Article: #{article.inspect}\n"
=end

  end

  def test_num_comments_wordpress
    article = Article.find(2)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 8 )
    puts "Article: #{article.inspect}\n"

    article = Article.find(5)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(6)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 16)
    puts "Article: #{article.inspect}\n"

    article = Article.find(7)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(8)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 13)
    puts "Article: #{article.inspect}\n"

    article = Article.find(10) #nytimes
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 73)
    puts "Article: #{article.inspect}\n"

    article = Article.find(11) #nytimes
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 21)
    puts "Article: #{article.inspect}\n"

    article = Article.find(13)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 1)
    puts "Article: #{article.inspect}\n"

    article = Article.find(17)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 14)
    puts "Article: #{article.inspect}\n"

    article = Article.find(18)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 36)
    puts "Article: #{article.inspect}\n"

    article = Article.find(19)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 23)
    puts "Article: #{article.inspect}\n"

    article = Article.find(23)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

=begin
jlk - don't know where this one went
    article = Article.find(26)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 1)
    puts "Article: #{article.inspect}\n"
=end
  end

  def test_num_comments_blogger_generic
    article = Article.find(4)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(9)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 8)
    puts "Article: #{article.inspect}\n"
  end
  def test_num_comments_blogger
    article = Article.find(4)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(9)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 8)
    puts "Article: #{article.inspect}\n"
  end

  def test_num_comments_sportsblogs_generic
    article = Article.find(20)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(21)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 14)
    puts "Article: #{article.inspect}\n"
  end


  def test_parse_text
    Article.find(:all).each {|a|
        f = File.new("#{a.url}.nokogiri.text")
        text = f.read
    #    puts "read text: #{text.inspect}"

        a.parse_text
        assert_parsed_article_text_correctly( a, text )
    }
  end

  def test_get_article_length
    a = Article.new
    a.text = "hello world\n"
    assert( 12 == a.get_article_length )
    a.text = ""
    assert( 0 == a.get_article_length )
    a.text = nil 
    assert( 0 == a.get_article_length )
  end

  def test_getCharCount
    a = Article.new
    e = nil
    n = Nokogiri::HTML( "<html><body><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p></body></html>" )
    assert( 0 == a.getCharCount2( e ) )
    paragraphs = n.search("//p")
    assert( 1 == a.getCharCount2( paragraphs[0] ) )
    assert( 2 == a.getCharCount2( paragraphs[1] ) )
    assert( 0 == a.getCharCount2( paragraphs[2] ) )

  end

  def test_cleanStyles
    a = Article.new
    e = nil
    assert( 0 == a.cleanStyles( e ) )
    n = Nokogiri::HTML( "<html><body><p style='style1'>test</p></body></html>" )
    assert( "style1" == n.search("//p")[0].get_attribute("style") )
    a.cleanStyles( n.search("//p")[0] )
    assert( nil == n.search("//p")[0].get_attribute("style") )

    n = Nokogiri::HTML( "<html><body><p style='style1'>test</p><span style='style2'>test<p style='style3'></p></span><p style='style4'></p></body></html>" )
    assert( "style1" == n.search("//p")[0].get_attribute("style") )
    assert( "style2" == n.search("//span")[0].get_attribute("style") )
    assert( "style3" == n.search("//p")[1].get_attribute("style") )
    assert( "style4" == n.search("//p")[2].get_attribute("style") )

    a.cleanStyles( n.search("//p")[0] )
    assert( nil == n.search("//p")[0].get_attribute("style") )

    a.cleanStyles( n.search("//p")[2] )
    assert( nil == n.search("//p")[2].get_attribute("style") )

    a.cleanStyles( n.search("//span")[0] )
    assert( nil == n.search("//span")[0].get_attribute("style") )
    #this style should clear itself recursively
    assert( nil == n.search("//p")[1].get_attribute("style") )
  end

  def test_killDivs
    a = Article.new
    e = nil
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><li>li1</li><li>li2</li><li>li3</li><li>li4</li></div></body></html>" )
    #case 1
    assert( 0 == a.killDivs( e ) )

    #case 2
    divs = n.search("//div")
    assert( 1 == divs.size )

    a.killDivs( n )

    divs = n.search("//div")
    assert( 0 == divs.size )

    #case 3
    n = Nokogiri::HTML( "<html><body><div><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><li>li1</li><li>li2</li><li>li3</li><li>li4</li></div></body></html>" )

    divs = n.search("//div")
    assert( 1 == divs.size )

    a.killDivs( n )

    divs = n.search("//div")
    assert( 1 == divs.size )

    #case 4
    n = Nokogiri::HTML( "<html><body><div class='footer'><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><li>li1</li><li>li2</li><li>li3</li><li>li4</li></div></body></html>" )

    divs = n.search("//div")
    assert( 1 == divs.size )

    a.killDivs( n )

    divs = n.search("//div")
    assert( 0 == divs.size )

    #case 5
    n = Nokogiri::HTML( "<html><body><div class='footer blogEntry'><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><li>li1</li><li>li2</li><li>li3</li><li>li4</li></div></body></html>" )

    divs = n.search("//div")
    assert( 1 == divs.size )

    a.killDivs( n )

    divs = n.search("//div")
    assert( 1 == divs.size )

  end

  def test_killBreaks
    a = Article.new
    e = nil
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br></p></div></body></html>" )
    
    assert( 0 == a.killBreaks( e ) )
    assert( 8 == n.search("//br").size )
    a.killBreaks( n )
    assert( 4 == n.search("//br").size )
  end

  def test_clean
    a = Article.new
    e = nil
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br></p></div></body></html>" )
    assert( 0 == a.clean( e, nil ) )

    #paragraphs = n.search("//p")
    #case 1
    assert( 3 == n.search("//p").size )
    a.clean( n, "p", 3 )

    assert( 2 == n.search("//p").size )
    
    #case 2
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br></p></div></body></html>" )
    assert( 3 == n.search("//p").size )
    a.clean( n, "p" ) #default minWords = 1000000
    assert( 0 == n.search("//p").size )

  end

  def test_format_article
    a = Article.new
    e = nil
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span class='blog_caption' style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br></p></div></body></html>" )

    assert( 0 == a.format_article( e ) )

    #case 1
    assert( 1 == n.search("//div").size )
    a.format_article( n )
    assert( 1 == n.search("//div").size )

    #case 2
    n = Nokogiri::HTML( "<html><body><div class='storypoll'><p style='style1'>test,</p><span class='blog_caption' style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br><cite>cite1</cite></p></div></body></html>" )
    assert( 1 == n.search("//div").size )
    a.format_article( n )
    assert( 0 == n.search("//div").size )

    #case 3
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span class='blog_caption' style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br><cite>cite1</cite></p></div></body></html>" )
    assert( 1 == n.search("//cite").size )
    a.format_article( n )
    assert( 0 == n.search("//cite").size )

    #case 4
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span class='blog_caption' style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br><cite>cite1</cite></p></div></body></html>" )
    assert( 1 == n.search("//span").size )
    a.format_article( n )
    assert( 0 == n.search("//span").size )

    #case 5
    n = Nokogiri::HTML( "<html><body><div class='article_body_caption'><p style='style1'>test,</p><span class='test' style='style2'>test<p style='style3'>hi,,   </p></span><p style='style4'><br><br> <br>\n<br>blah<br>blah <br>\n<br>s<br><cite>cite1</cite></p></div></body></html>" )
    assert( 1 == n.search("//span").size )
    a.format_article( n )
    assert( 1 == n.search("//span").size )
  end

  def test_format_text
    #jlk todo - need to add some real tests here
    assert( 0 )
  end

  def test_check_for_teams_mentioned
    a = Article.new
    str = nil
    #p "return: #{a.check_for_teams_mentioned( str )}\n"
    #assert( "" === a.check_for_teams_mentioned( str ) )

    str = "Celtics"
    a.check_for_teams_mentioned_basketball( str )
    assert( /Celtics/ =~ a.teams_mentioned )

    str = "Celtics Phoenix Suns"
    a.check_for_teams_mentioned_basketball( str )
    assert( /Celtics/ =~ a.teams_mentioned && /Suns/ =~ a.teams_mentioned )

    str = "eltics"
    a.check_for_teams_mentioned_basketball( str )
    assert( 0 == a.teams_mentioned.length )

    str = "Arizona Cardinals"
    a.check_for_teams_mentioned( str )
    assert( /Cardinals/ =~ a.teams_mentioned )

    str = "Tim Duncan"
    a.check_for_players_mentioned_basketball( str )
    assert( /Duncan/ =~ a.players_mentioned )
    
    str = "Tim Duncan Steve Nash"
    a.check_for_players_mentioned_basketball( str )
    assert( /Duncan/ =~ a.players_mentioned && /Nash/ =~ a.players_mentioned )
    
    str = "Tim Dncan"
    a.check_for_players_mentioned_basketball( str )
    assert( 0 == a.players_mentioned.length )
=begin
    str = "Tom Brady"
    a.check_for_players_mentioned( str )
    assert( /Brady/ =~ a.players_mentioned )
    
    str = "Tom Brady Peyton Manning"
    a.check_for_players_mentioned( str )
    assert( /Brady/ =~ a.players_mentioned && /Manning/ =~ a.players_mentioned )
    
    str = "Tim Dncan"
    a.check_for_players_mentioned( str )
    assert( 0 == a.players_mentioned.length )
=end
  end

  def test_parse_title
    a = Article.new
    e = nil

    a.title = nil
    a.parse_title
    p "hide: #{a.hide}\n"
    assert( false == a.hide )

    a.title = ""
    a.parse_title
    assert( false == a.hide )

    a.title = "open thread"
    a.parse_title
    assert( true == a.hide )

    a.title = "thread"
    a.parse_title
    assert( false == a.hide )

  end

  def test_fill_publication_name
    a = Article.new
    a.publication_name = "rss.espn.go.com"

    a.url = "http://sports.espn.go.com/nhl/recap?gameId=300210010"
    a.fill_publication_name
    assert( "sports.espn.go.com" == a.publication )

    a.url = ""
    a.fill_publication_name
    assert( "rss.espn.go.com" == a.publication )

  end

  def test_get_site_ranking
    #jlk todo
  end

  def test_calculate_inbound_links

    a1 = Article.create( :url => "link1.html" )
    a2 = Article.create( :url => "link2.html" )
    a3 = Article.create( :url => "link3.html" )
    a4 = Article.create( :url => "link4.html" )
    a5 = Article.create( :url => "link5.html" )

    n = Nokogiri::HTML( "<html><body><div><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><a href='link2.html'>s</a><a href='link5.html'>s</a></div><a href='link3.html'>fd</a></body></html>" )
    a1.calculate_outbound_links( n.search("//div") )

    n = Nokogiri::HTML( "<html><body><div><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><a href='link1.html'>f</a><a href='link2.html'>s</a><a href='link5.html'>s</a></div><a href='link3.html'>fd</a></body></html>" )
    a2.calculate_outbound_links( n.search("//div") )

    n = Nokogiri::HTML( "<html><body><div><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><a href='link5.html'>s</a><a href='link4.html'>s</a><a href='link4.html'>s</a></div></body></html>" )
    a3.calculate_outbound_links( n.search("//div") )


    a1.calculate_inbound_links
    a2.calculate_inbound_links
    a3.calculate_inbound_links
    a4.calculate_inbound_links
    a5.calculate_inbound_links

    #count single link
    assert( 1 == a1.num_backward_links )

    #count multiple links
    assert( 3 == a5.num_backward_links )

    #don't count links out of the div
    assert( 0 == a3.num_backward_links )

    #no self-links
    assert( 1 == a2.num_backward_links )
    
    #multiple links should only count once
    assert( 1 == a4.num_backward_links )
  end

  def test_calculate_outbound_links
    article = Article.new

    n = Nokogiri::HTML( "<html><body><div><p style='style1'>test,</p><span style='style2'>test<p style='style3'>hi,,</p></span><p style='style4'></p><a href='link1.html'>f</a><a href='link2.html'>s</a></div><a href='link3.html'>fd</a></body></html>" )

    divs = n.search("//div")
    assert( divs )
    assert( 1 == divs.size )

    article.calculate_outbound_links( divs[0] )

    assert( 2 == article.links.size )
    puts "Article: #{article.inspect}\n"


    #test a "real" article
    a = Article.find(10)
    a.evaluate_article
    assert( 5 == a.links.size )#This verifies that double links only count as one
  end

  def test_num_comments_sportsblogs
    article = Article.find(20)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(21)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 14)
    puts "Article: #{article.inspect}\n"
  end
  def test_num_comments_redirection_sites
    article = Article.find(1)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_greater_or_equal_than_the_number_comments( article, 5)
    puts "Article: #{article.inspect}\n"

=begin
jlk - this doesn't work right now (cbs stuff changed)
    article = Article.find(16)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_greater_or_equal_than_the_number_comments( article, 43)
    puts "Article: #{article.inspect}\n"

    article = Article.find(24)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_greater_or_equal_than_the_number_comments( article, 71)
    puts "Article: #{article.inspect}\n"
=end

    article = Article.find(25)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_greater_or_equal_than_the_number_comments( article, 4)
    puts "Article: #{article.inspect}\n"
  end

  def test_num_comments_generic
    article = Article.find(12)
    assert article
    article.get_number_of_comments_generic( article.url )
    #jlk - this doesn't work right now assert_parsed_correct_number_comments( article, 50)#on page 1, 483 overall
    puts "Article: #{article.inspect}\n"

    article = Article.find(14)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(15)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 4)
    puts "Article: #{article.inspect}\n"

    article = Article.find(22)
    assert article
    article.get_number_of_comments_generic( article.url )
    assert_parsed_correct_number_comments( article, 5)
    puts "Article: #{article.inspect}\n"

    #article = Article.find(3)
    #assert article
    #article.get_number_of_comments_generic( article.url )
    #assert_parsed_correct_number_comments( article, 39)
    #puts "Article: #{article.inspect}\n"

  end
  def test_num_comments
    article = Article.find(12)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 50)#on page 1, 483 overall
    puts "Article: #{article.inspect}\n"

    article = Article.find(14)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 3)
    puts "Article: #{article.inspect}\n"

    article = Article.find(15)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 4)
    puts "Article: #{article.inspect}\n"

    article = Article.find(22)
    assert article
    article.get_number_of_comments( article.url )
    assert_parsed_correct_number_comments( article, 5)
    puts "Article: #{article.inspect}\n"

    #article = Article.find(3)
    #assert article
    #article.get_number_of_comments( article.url )
    #assert_parsed_correct_number_comments( article, 39)
    #puts "Article: #{article.inspect}\n"

  end
end
