#!/usr/bin/ruby

require 'rubygems'
require 'logger'
require 'active_record'
require 'rufus/scheduler'
require 'sqlite3'
#We have to 'require' these two files first as subclasses depend on them
require 'app/models/team.rb'
require 'app/models/article.rb'
Dir["app/models/*.rb"].each {|file| require file }


  rufus_logfile = File.open("/home/deviagaz/bballmeme/log/sched.log", 'a')
  rufus_logfile.sync = true
  RUFUS_LOG = Logger.new(rufus_logfile)

RUFUS_LOG.info "[rufus] starting rufus-sched app...#{Time.now}\n"

s = Rufus::Scheduler.start_new
s1 = Rufus::Scheduler.start_new
s2 = Rufus::Scheduler.start_new
  sql = ActiveRecord::Base.establish_connection(
              :adapter => 'mysql',
              :database => 'deviagaz_bballmeme',
              :username => 'deviagaz_rails',
              :password => 'password',
              :host => 'localhost',
              :port => 3306)
r = ActiveRecord::Base.connection.execute("set names utf8 collate utf8_general_ci")

=begin
  sql = ActiveRecord::Base.establish_connection(
              :adapter => 'sqlite3',
              :database => '/home/deviagaz/bballmeme/db/production.sqlite3',
              :timeout => 15000
              )
=end


s.every "5m" do 
  RUFUS_LOG.info "[rufus1] Waking up, rescoring all the articles #{Time.now}"
  r = Ranker.new
  r.rescore_articles
  RUFUS_LOG.info "[rufus1] Done rescoring all the articles #{Time.now}"
end

s1.every "1m", :blocking => true do
  RUFUS_LOG.info "[rufus] Waking up, dequeue FIFO #{Time.now}"
  f = FifoDequeue.new
  f.read_from_fifo_db_wrapper
  RUFUS_LOG.info "[rufus] Done dequeue FIFO #{Time.now}"
end

s2.every "30m" do
  RUFUS_LOG.info "[rufus] Waking up, refresh cache #{Time.now}"
  #expire_page :controller => 'articles', :action => 'index'
  
  #system("rm -rf public/index.html")
  #system("rm -rf public/articles")
  system("rm -rf public/tmp/cache/views")
  system("rm -rf tmp/cache/views")

  system("rm -rf public/teams")


  Team.find(:all).each { |team|
    #expire_page :controller => 'teams', :action => 'show', :id => id
    #expire_page :controller => 'teams', :action => 'hot', :id => id
    #expire_page :controller => 'teams', :action => 'local', :id => id
    #expire_page :controller => 'teams', :action => 'national', :id => id
    #expire_page :controller => 'teams', :action => 'blogs', :id => id
  }
  RUFUS_LOG.info "[rufus] Done refresh cache #{Time.now}"
end




#run this indefinitely
while (1)
   sleep(1) 
end
