class FeedbacksController < ApplicationController
  # GET /feedbacks
  # GET /feedbacks.xml
  def index
      redirect_to :action => 'submit_feedback'
  end

  def submit_feedback
    if(params[:feedback])
       @fr = Feedback.new
       @fr.type = params[:feedback][:type]
       @fr.created_at = Time.now
       @fr.submitter = params[:feedback][:submitter]
       @fr.text = params[:feedback][:text]
       #@fr.admin_notes = 1
       if @fr.save
          flash[:notice] = "Thank you for submitting feedback!"
       else
	  flash[:notice] = "There was an error in processing your feedback"
       end
    else
       flash[:notice]  = ''
       respond_to do |format|
      	 format.html # new.html.erb
      	 format.xml  { render :xml => @feedback }
       end
    end
  end	

 
	
=begin non user visible stuff

  # GET /feedbacks/1
  # GET /feedbacks/1.xml
  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # GET /feedbacks/1/edit
  def edit
    @feedback = Feedback.find(params[:id])
  end

  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    @feedback = Feedback.new(params[:feedback])

    respond_to do |format|
      if @feedback.save
        flash[:notice] = 'Feedback was successfully created.'
        format.html { redirect_to(@feedback) }
        format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.xml
  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        flash[:notice] = 'Feedback was successfully updated.'
        format.html { redirect_to(@feedback) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.xml
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to(feedbacks_url) }
      format.xml  { head :ok }
    end
  end

=end

end
