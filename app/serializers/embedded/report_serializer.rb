class Embedded::ReportSerializer < ActiveModel::Serializer
  attributes :id,:user_id,:branch_id,:name,:created_at,:created_by,:created_in

  def created_at
    object.created_at.strftime("%d/%m/%Y %I:%M%p")
  end
end
