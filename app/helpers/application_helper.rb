# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def page_title( root_url )
    page_title = case root_url
    when /fballnews/i: "FBALLNEWS - Frontpage Football News"
    when /bballnews/i: "BBALLNEWS - Frontpage Basketball News"
    else "Frontpage News"
    end
  end

  def short_sport_name( root_url )
    short_sport_name = case root_url
    when /fballnews/i: "FBALL"
    when /bballnews/i: "BBALL"
    else "BALL"
    end
  end

  def slogan( root_url )
    slogan = case root_url
    when /fballnews/i: "Frontpage Football News"
    when /bballnews/i: "Frontpage Basketball News"
    else "BALL"
    end
  end

  def copyright_notice( root_url )
    slogan = case root_url
    when /fballnews/i: "Copyright 2009, 2010 FBALLNEWS.com"
    when /bballnews/i: "Copyright 2009, 2010 BBALLNEWS.com"
    else "BALL"
    end
  end

  def determine_teams_controller( root_url )
    controller = case root_url
    when /fballnews/i: "fb_teams"
    when /bballnews/i: "bb_teams"
    else "BALL"
    end
  end

  def sport_prefix( root_url )
    controller = case root_url
    when /fballnews/i: "fb"
    when /bballnews/i: "bb"
    else ""
    end
  end

  def affiliate_sites( root_url )
    site = case root_url
    when /fballnews/i: "<a href=\"http://www.bballnews.com\">BBALLNEWS.COM</a>"
    when /bballnews/i: "<a href=\"http://www.fballnews.com\">FBALLNEWS.COM</a>"
    else ""
    end
  end

  def get_article_text( article )
    if ( !article.rss_description.nil? && 
        (article.rss_description != "" || article.publication_name =~ /dallasnews|feeds\.foxsports\.com|ballhype/i) && 
        (article.rss_description.size >= 300 || article.publication_name =~ /cbssports|feeds\.latimes\.com|dallasnews|feeds\.foxsports\.com|71084|71095|ballhype/i) 
        #&&(!article.publication_name =~ /(peachtreehoops|celticsblog|rufusonfire|blogabull|fearthesword|detroitbadboys|indycornrows|peninsulaismightier|brewhoop|netsdaily|postingandtoasting|orlandopinstripedpost|libertyballers|raptorshq|bulletsforever|mavsmoneyball|denverstiffs|goldenstateofmind|thedreamshake|clipsnation|silverscreenandroll|straightouttavancouver|canishoopus|atthehive|welcometoloudcity|brightsideofthesun|blazersedge|sactownroyalty|poundingtherock|slcdunk|swishappeal|ridiculousupside)\.com/i)
       )
          return "#{article.rss_description[0..300]}..."
    elsif !article.text.nil? 
      return "#{article.text[0..300]}..."
    end
  end
end
