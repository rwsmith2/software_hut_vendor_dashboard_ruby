# == Schema Information
#
# Table name: assignments
#
#  complete      :boolean          default(FALSE)
#  complete_by   :date
#  verified      :boolean          default(FALSE)
#  assignment_id :integer          not null, primary key
#  given_task_id :integer          not null
#  vendor_id     :integer          not null
#
# Foreign Keys
#
#  fk_rails_...  (given_task_id => given_tasks.given_task_id) ON DELETE => cascade
#  fk_rails_...  (vendor_id => vendors.vendor_id) ON DELETE => cascade
#
class Assignment < ApplicationRecord
  has_many :vendor_answers,  dependent: :destroy
  belongs_to :given_task
  belongs_to :vendor

  accepts_nested_attributes_for :vendor_answers, allow_destroy: true
  validates_associated :vendor_answers

  #Checks to see if the vendor has already submitted any answers
  def check_if_already_answered
    if self.vendor_answers.size != 0
      return true
    end
    return false
  end

  #Sets the assignment to complete
  def complete_assignment
    self.update(complete: true)
  end
end
