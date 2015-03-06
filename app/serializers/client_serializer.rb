class ClientSerializer < ActiveModel::Serializer
  attributes :id,:name,:qty_reports,:qty_branches,:qty_employees
end
