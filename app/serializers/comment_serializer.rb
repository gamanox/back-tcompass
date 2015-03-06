class CommentSerializer < ActiveModel::Serializer
  attributes :id,:content,:user_id,:created_by,:created_at

  def created_at
    object.created_at.strftime("%d/%m/%Y")
  end

  def created_by
    object.user.name
  end
end
