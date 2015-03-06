class PageSerializer < ActiveModel::Serializer
  attributes :id,:report_id,:title
  has_many :questions,serializer: QuestionSerializer
end
