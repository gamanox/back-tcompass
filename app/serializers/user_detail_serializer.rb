class UserDetailSerializer < ActiveModel::Serializer
  attributes :id,:name,:last_name,:is_active
end
