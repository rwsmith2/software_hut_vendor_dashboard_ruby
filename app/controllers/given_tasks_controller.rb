# Controller used to handle Given Tasks
class GivenTasksController < ApplicationController
  require 'date'
  authorize_resource

  #GET    /admin/given_tasks(.:format) 
  def index
    @current_nav_identifier = :given_tasks
    #Fetch all given tasks, joining with task table to retrieve task_title
    @pagy, @given_tasks = pagy(GivenTask.joins(:task).all.select("given_task_id, task_title"), items: 10)
    @selected = GivenTask.first
  end

  #GET    /fetch_given_task(.:format)
  def select_given_task
    #Get the selected given task and format the javascript
    @selected = GivenTask.find(params[:given_task_id])
    respond_to do |format|
      format.js
    end
  end

  #GET    /given_tasks/:id/edit(.:format) 
  def edit
    @editing = true
    @given_task = GivenTask.find(params[:id])
    render layout: false
  end

  # PATCH  /given_tasks/:id(.:format)
  def update
    @given_task = GivenTask.find(params[:id])
    @given_task.due_date = given_task_params[:due_date]
    @given_task.priority = GivenTask.priority_string_to_int(given_task_params[:priority])
    @given_task.repeatable = GivenTask.if_empty_repeatable_set_to_0(given_task_params[:repeatable].to_i)
    if @given_task.save
      Assignment.where(given_task_id: @given_task.given_task_id, complete_by: @given_task.due_date).destroy_all
      if params[:given_task][:assignments_attributes] != nil
        params[:given_task][:assignments_attributes].each_value do |value|
          assignment = Assignment.new
          assignment.vendor_id = value[:vendor_id]
          assignment.complete = false
          assignment.given_task_id = @given_task.given_task_id
          assignment.complete_by = @given_task.due_date
          assignment.save
        end
      end
      #Update the priority attribute, after converting form string to int
      @given_task.update(priority: GivenTask.priority_string_to_int(given_task_params[:priority]))
      @given_task = GivenTask.joins(:task).all.select("given_task_id, task_title")
      @pagy, @given_tasks = pagy(GivenTask.joins(:task).all.select("given_task_id, task_title"), items: 10)
      render 'given_task_success_update'
    else
      render 'given_task_failure'
    end
  end

  # GET    /given_tasks/new(.:format)
  def new 
    #Initialize and build new given task
    session[:task_id] = params[:task_id]
    @editing = false
    @given_task =  GivenTask.new
    @given_task.assignments.build
    #Fetch vendors, so they can be used as collection to populate dropdown
    @vendors = Vendor.all
    #False because its a modal
    render layout: false
  end

  #DELETE /given_tasks/:id(.:format)
  def destroy
    #Fetch given task and destroy
    @given_task_destroy = GivenTask.find(params[:id])
    @given_task_destroy.destroy
    redirect_to given_tasks_path, notice: 'Task was successfully destroyed.'
  end

  #POST   /given_tasks/search(.:format)
  def search
    @pagy, @given_tasks = pagy(GivenTask.joins(:task).all.where('tasks.task_title LIKE ?', "%#{params[:search][:assessment_title]}%").select("given_task_id, task_title"), items:10)
    render 'search_refresh'
  end


  # POST   /given_tasks(.:format)
  def create
    @given_task = GivenTask.new(given_task_params)
    @given_task.task_id = session[:task_id]
    #Convert priority from string value to int value
    @given_task.priority = GivenTask.priority_string_to_int(given_task_params[:priority])
    @given_task.set_date = Date.today
    #Convert string to date
    #@given_task.due_date  = Date.strptime(given_task_params[:due_date],  "%d-%m-%Y")
    @given_task.due_date  = given_task_params[:due_date]
    #Validate to check if repeatable is empty
    @given_task.repeatable = GivenTask.if_empty_repeatable_set_to_0(given_task_params[:repeatable].to_i)
    if @given_task.save
      latest_given_task_id = (GivenTask.last).given_task_id
      assignments = Assignment.where(given_task_id: latest_given_task_id)
      assignments.each do |assignment|
        assignment.complete_by = @given_task.due_date
        assignment.save
      end
      params[:given_task][:assignments_attributes].each_value do |value|
        vendor = Vendor.find(value[:vendor_id])
        user = vendor.user
        @email = user.email
        @name = vendor.company_name
        #Email vendors to notify they have received a new task
        TaskMailer.with(email: @email, name: @name).task_assigned_email.deliver_now
      end
      render 'given_task_success_create'
    else
      render 'given_task_failure'
    end
  end

  private
    def given_task_params
      #Fetch given task params, with nested assignment attributes
      params.fetch(:given_task, {}).permit(:due_date, :priority, :repeatable, :task_id, 
        assignments_attributes: [:assignment_id,:vendor_id ,:_destroy, :id])
    end

    def given_task_params_without_assignments
      #Fetch given task params, with nested assignment attributes
      params.fetch(:given_task, {}).permit(:due_date, :priority, :repeatable, :task_id, assignments_attributes:[:assignment_id,:vendor_id ,:_destroy, :id])
    end

end