class BranchSerializer < ActiveModel::Serializer
  attributes :id,:name,:address,:latlng,:is_active
end
