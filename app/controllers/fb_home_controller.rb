class FbHomeController < HomeController

  def grab_teams
    @teams = FBTeam.find(:all)
    #flash[:notice] = "params: #{params.inspect} session: #{session.inspect} request: #{request.inspect}\n headers: #{headers.inspect}\n cookies: #{cookies.inspect}\n response: #{response.inspect}\n"
    if @teams.nil?
        flash[:notice] = "There are no teams\n"
    end
  end

end
