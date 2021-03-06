# Controller used to handle completed tasks 
class CompletedtasksController < ApplicationController
  before_action :authenticate_user!

  #GET    /completedtasks/index(.:format)
  def index
    @current_nav_identifier = :completedtasks_index
    #Load all completed tasks for the specific vendor
    @joined= Assignment.joins(:given_task).merge(GivenTask.joins(:task)).select(:assignment_id, :task_title, :due_date, :set_date, :complete).where("complete=true AND vendor_id= ?", Vendor.get_vendor_id(current_user.user_id))
    @pagy, @tasks = pagy(@joined.order(params[:sort]), items: 10)
    render :index
  end
end
