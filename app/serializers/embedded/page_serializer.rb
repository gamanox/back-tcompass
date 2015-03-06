class Embedded::PageSerializer < ActiveModel::Serializer
  attributes :id,:report_id,:title,:responses
  has_many :questions,serializer: Embedded::QuestionSerializer

  # Responses for app's reports archive
  def responses
    object.questions.map do |q|
      Embedded::ResponseSerializer.new(q.filtered_responses.first,root: false)
    end
  end
end
