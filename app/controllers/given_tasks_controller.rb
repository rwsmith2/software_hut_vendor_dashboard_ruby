class GivenTasksController < ApplicationController
  require 'date'
  authorize_resource

  def index
    @pagy, @given_tasks = pagy(GivenTask.joins(:task).all.select("given_task_id, task_title"), items: 10)
    puts(@given_tasks.inspect)
    #@given_tasks = GivenTask.all.select("given_task_id, task_title")
    @selected = GivenTask.first
  end

  def select_given_task
    @selected = GivenTask.find(params[:given_task_id])
    puts(@selected.inspect)
    respond_to do |format|
      format.js
    end
  end

  def edit
    @given_task = GivenTask.find(params[:id])
    render layout: false
  end

  def update
    @given_task = GivenTask.find(params[:id])
    if @given_task.update(given_task_params)
      @given_task.update(priority: GivenTask.priorityStringToInt(given_task_params[:priority]))
      @given_task = GivenTask.joins(:task).all.select("given_task_id, task_title")
      redirect_to admin_assessments_path, notice: 'Assessment was successfully updated.'
    else
      puts(@given_task.errors.full_messages)
      render :edit
    end
  end

  # GET /tasks/new
  def new 
    session[:task_id] = params[:task_id]
    #@task_id = params[:task_id]
    @given_task =  GivenTask.new
    @given_task.assignments.build
    @vendors = Vendor.all
    
    render layout: false
  end

  def destroy
    @given_task_destroy = GivenTask.find(params[:id])
    @given_task_destroy.destroy
    redirect_to given_tasks_path, notice: 'Task was successfully destroyed.'
  end

  def search
    #GivenTask.joins(:task).where('tasks.task_title LIKE ?', '%test%')
    #@pagy, @given_tasks = pagy(GivenTask.joins(:task).where('tasks.task_title LIKE ?', '%test%'), items: 10)
    #GivenTask.joins(:task).where('tasks.task_title LIKE ?', "%#{params[:search][:assessment_title]}%")
    @pagy, @given_tasks = pagy(GivenTask.joins(:task).all.where('tasks.task_title LIKE ?', "%#{params[:search][:assessment_title]}%").select("given_task_id, task_title"), items:10)
    puts(@given_tasks.inspect)
    render 'search_refresh'
  end


  # POST /tasks
  def create
    @given_task = GivenTask.new(given_task_params)
    @given_task.task_id = session[:task_id]
    @given_task.priority = GivenTask.priorityStringToInt(given_task_params[:priority])
    @given_task.set_date = Date.today
    @given_task.due_date  = Date.strptime(given_task_params[:due_date],  "%d-%m-%Y")
    @given_task.repeatable = GivenTask.ifEmptyRepeatableSetTo0(given_task_params[:repeatable].to_i)
    puts(@given_task.repeatable)
    if @given_task.save
      redirect_to admin_assessments_path, notice: 'Task was successfully assigned'
    else
      render :new
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_task
  #   @task = Task.find(params[:id])
  # end

  def given_task_params
    params.fetch(:given_task, {}).permit(:due_date, :priority, :repeatable, :task_id, assignments_attributes: [:assignment_id,:vendor_id ,:_destroy, :id])
  end



  #This is used if no assessment is needed to be linked
  # def task_params_no_assessment
  #   params.fetch(:task, {}).permit(:task_title, :task_description, :estimation)
  # end
  
end