class Page < ActiveRecord::Base
  belongs_to :report
  has_many :questions,dependent: :destroy

  accepts_nested_attributes_for :questions
end
