# == Schema Information
#
# Table name: questions
#
#  question_text :string           not null
#  assessment_id :integer
#  question_id   :integer          not null, primary key
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.assessment_id)
#
class Question < ApplicationRecord
  has_many :answers, dependent: :delete_all
  belongs_to :assessment, optional: true
  accepts_nested_attributes_for :answers, allow_destroy: true

  validates_associated :answers
  validates :question_text, presence: true, length: { in: 5..100}
  validate :validate_answer_count

  #Validates the answer count is at least 1
  def validate_answer_count 
    if self.answers.size < 1
      errors.add(:answers, "- Need 1 or more answers")
    end
  end

  #Gets the question object, from answer_id input
  def self.get_question_from_answer(answer_id)
    question_id = Answer.find(answer_id).question_id
    question = Question.find(question_id)
    return question
  end

end
