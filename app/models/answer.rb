# == Schema Information
#
# Table name: answers
#
#  additional_response :string
#  answer_text         :string           not null
#  answer_id           :integer          not null, primary key
#  question_id         :integer
#
# Foreign Keys
#
#  question_id  (question_id => questions.question_id) ON DELETE => cascade
#
class Answer < ApplicationRecord
    belongs_to :question, optional: true
end
