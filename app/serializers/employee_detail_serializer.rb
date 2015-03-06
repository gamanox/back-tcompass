class EmployeeDetailSerializer < ActiveModel::Serializer
  include UsersHelper

  attributes :id,:name,:groups,:is_active

  def name
    full_name(object.name,object.last_name)
  end

  def groups
    object.in_groups.map {|g| g.name}.join(',')
  end
end
