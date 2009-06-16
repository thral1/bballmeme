class HomeController < ApplicationController
  layout 'articles'
  before_filter :grab_teams
  caches_action :aboutus, :cache_path => Proc.new {|controller| controller.params }
  caches_action :advertise, :cache_path => Proc.new {|controller| controller.params }
  caches_action :contact, :cache_path => Proc.new {|controller| controller.params }

  def grab_teams
    @teams = Team.find(:all)
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
  end

  def index
  end

  def about
  end

  def contact 
  end

  def help
  end

  def submit_feedback
    Feedback.create { |f|
      f.text = params[:feedback][:text]
      f.submitter = params[:feedback][:submitter]
      f.submitter_email = params[:feedback][:submitter_email]
    }
  end
end
