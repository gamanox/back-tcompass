class ReportDetailSerializer < ActiveModel::Serializer
  attributes :id,:title,:description,:place_name,:is_active
  has_many :pages,serializer: Embedded::PageSerializer
  has_many :groups,serializer: GroupSerializer
end
