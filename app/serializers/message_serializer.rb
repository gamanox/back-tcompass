class MessageSerializer < ActiveModel::Serializer
  include UsersHelper

  # INFO: this is_read is for the employee (android app)
  attributes :id,:user_id,:title,:content,:created_by,:created_at,:scope_count,
    :is_read,:meta_data
  has_many :comments,serializer: CommentSerializer

  def created_at
    object.created_at.strftime("%d/%m/%Y")
  end

  def created_by
    object.user.name
  end

  # INFO: this is_read is for the admin (web dashboard)
  def meta_data
    u_ids = object.message_status.user_ids
    {
      read_by_count: u_ids.count,
      read_by: User.select(:id,:name,:last_name).where("users.id IN (?)",u_ids).map {|u| {id: u.id,name: full_name(u.name,u.last_name)}},
      is_read: object.read
     }
  end

  def scope_count
    object.scope_count
  end
end
