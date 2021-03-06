# Controller used to handle Assessments 
class AssessmentsController < ApplicationController
  include Pagy::Backend

  #Before actions
  before_action :authenticate_user!
  before_action :set_assessment, only: [:_edit_question, :select_assessment]
  before_action :set_assessment_destroy_edit, only: [:destroy, :edit ,:update]

  #GET /assessments(.:format)
  def index 
    @answer_exists = false
    @current_nav_identifier = :assessments_index
    #Gets the list of all assessments, and also creates a pagy object
    @pagy, @assessments = pagy(Assessment.all, items: 10)
    #fetch the assessment for a specific vendor
    @user = current_user
    @vendor = Vendor.find_by(user_id: @user.user_id)
    @joined = Assignment.joins(:given_task).select(:task_id).where("complete=false")
    @tasks = @joined.where(vendor_id: @vendor.vendor_id)
  end

  #GET    /assessments/questions(.:format)
  def questions
    @assessment = Assessment.find(params[:assessment_id])
    @assignment = Assignment.find(params[:assignment_id])
    @vendor = Vendor.find_by(user_id: current_user)
    @questions = Question.where("assessment_id=?", @assessment.assessment_id)
    @vendor_assignment = Assignment.where(vendor_id: @vendor.vendor_id)
    #Check to see if there is an error to be displayed
    if params[:error] != nil
      @error = params[:error]
    else
      @error = ""
    end

    #Save data to sessions
    session[:return_to] ||= request.referer
    session[:assignment_id] = params[:assignment_id]
    session[:assessment_id] = params[:assessment_id]
  end

  #POST   /assessments/save_questions(.:format)
  def save_questions
    @assignment = Assignment.find(session[:assignment_id])
    @assessment = Assessment.find(session[:assessment_id])

    @answered_all = true
    @answer_exists = false
    
    @previous_answers = VendorAnswer.find_by(assignment_id: session[:assignment_id])
    
    #Loops through checking to see if all questions are answered
    params.each do |answer|
      if answer[1] == ""
        @answered_all = false
      end
    end


    #If already answered, delete the previous answers, as they will be replaced
    if(@assignment.check_if_already_answered)
      delete_answers = VendorAnswer.where(assignment_id: session[:assignment_id])
      delete_answers.delete_all
    end

    params.each do |answer|
      if(Assessment.is_number?(answer[1]))
        @vendor_answer = VendorAnswer.new
        @vendor_answer.assignment_id = session[:assignment_id]
        @vendor_answer.answer_id = answer[1]
        @vendor_answer.save(validate: false)
      end
    end

    if(@answered_all == true)
      redirect_to assessments_review_path(@vendor_answer)
    else
      #If all answers aren't saved, give a pop up
      @error = "Please answer all questions"
      redirect_to assessments_questions_path(assignment_id: session[:assignment_id], assessment_id: session[:assessment_id], error: @error)
    end
    
  end
  
  #GET    /assessments/review(.:format)
  def questions_review
    @assessments = Assessment.find(session[:assessment_id])
    @assignment = Assignment.find(session[:assignment_id])
    @page, @questions = pagy(Question.where("assessment_id=?", @assessments.assessment_id), items: 4)
    @question = @questions.count
    @questionsCoun = @question/4.0
  end

  #POST   /assessments/submit(.:format)
  def submit
    @assignment = Assignment.find(session[:assignment_id])
    if @assignment.update(submit_params)
      @assignment.complete_assignment()
      redirect_to vendor_home_path, notice: 'Assessment was successfully updated.'
    else
      render :questions_review
    end
  end
  
  #GET /admin/assessments/new
  def new 
    #Initialize a new assessment object and build the questions and answers
    @assessment = Assessment.new
    @assessment.questions.build.answers.build
  end
  
  #GET /admin/assessments(.:format) 
  def admin_index
    @current_nav_identifier = :admin_assessments
    #Gets the list of all assessments, with pagy. Also selects the first assessment
    @pagy, @assessments = pagy(Assessment.all, items: 10)
    @selected= Assessment.first
  end

  #GET /assessments/:id/edit
  def edit
    #Find the selected assessment
    @assessment = Assessment.find(params[:id])
  end


  #POST /assessments/search
  def search
    #Create a list of assessments matching the search query
    @pagy, @assessments = pagy(Assessment.where("assessment_title LIKE ?","%#{params[:search][:assessment_title]}%"), items:10)
    render 'search_refresh'
  end

  #GET /fetch_assessment
  def select_assessment
    #Get the selected assessment and format the javascript
    @selected = Assessment.find(params[:assessment_id])
    respond_to do |format|
      format.js
    end
  end

  #POST /assessments
  def create
    #Create an assessment object with the assessment_params
    @assessment = Assessment.new(assessment_params)
    if @assessment.save
      redirect_to admin_assessments_path, notice: 'Assessment was successfully created'
    else
      render :new
    end
  end

  #PATCH /assessments/:id
  def update
    #Find the selected assessment object and update it through the assessment_update_params
    @assessment = Assessment.find(params[:id])
    if @assessment.update(assessment_update_params)
      redirect_to admin_assessments_path, notice: 'Assessment was successfully updated.'
    else
      render :edit
    end
  end

  #DELETE /assessments/:id
  def destroy
    #Find the assessment you want to delete and destroy it
    @assessment_destroy_edit = Assessment.find(params[:id])
    @assessment_destroy_edit.destroy
    redirect_to admin_assessments_path, notice: 'Assessment was successfully destroyed.'
  end

  def upload
    @vendor_answers = VendorAnswer.new(vendor_answers)
  end

  private
  #Setter methods to set the assessment object
  def set_assessment
    @assessment = Assessment.find(params[:assessment_id])
  end

  def set_assessment_destroy_edit
    @assessment_destroy_edit = Assessment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def assessment_params
    #Fetch params for assessment, including nested attributes for questions and answers
    params.fetch(:assessment, {}).permit(:assessment_title,
     questions_attributes: [:question_id, :question_text, :_destroy,
      answers_attributes: [:answer_id, :answer_text, :additional_response, :upload_needed,:comment_needed, :_destroy]])
  end

  def assessment_update_params
    #Fetch params for assessment, including nested attributes for questions and answers
    params.fetch(:assessment, {}).permit(:id, :assessment_title,
     questions_attributes: [:id, :question_text, :_destroy,
      answers_attributes: [:id, :answer_text, :additional_response, :upload_needed, :comment_needed ,:_destroy]])
  end


  def submit_params
    #Fetch params for submitting an assignment
    params.require(:assignment).permit(:id, vendor_answers_attributes: [:id, :upload, :comment])
  end
  
end
