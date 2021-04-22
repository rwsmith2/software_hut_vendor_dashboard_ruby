# == Schema Information
#
# Table name: vendor_answers
#
#  id            :integer          not null, primary key
#  answer_id     :integer
#  assignment_id :integer
#
# Foreign Keys
#
#  answer_id      (answer_id => answers.answer_id)
#  assignment_id  (assignment_id => assignments.assignment_id) ON DELETE => cascade
#