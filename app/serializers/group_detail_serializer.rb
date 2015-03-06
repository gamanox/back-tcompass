class GroupDetailSerializer < GroupSerializer
  has_many :users,serializer: UserDetailSerializer

  def users
    GroupsUser.where(group_id: object.id).map {|gu| gu.user}
  end
end
