class QuestionSerializer < ActiveModel::Serializer
  attributes :id,:page_id,:report_id,:question_type,:title,:options,:skus

  def report_id
    object.page.report.id
  end
end
