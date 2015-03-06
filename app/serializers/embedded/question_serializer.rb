class Embedded::QuestionSerializer < ActiveModel::Serializer
  attributes :id,:page_id,:report_id,:question_type,:title,:options,:skus,
    :responses

  def report_id
    object.page.report.id
  end

  def responses
    object.detail_responses
  end
end
