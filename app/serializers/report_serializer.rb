class ReportSerializer < ActiveModel::Serializer
  attributes :id,:title,:description,:is_active
  has_many :pages,serializer: PageSerializer
end
