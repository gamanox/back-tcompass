class ReportTableSerializer < ActiveModel::Serializer
  attributes :id,:title,:groups,:is_active

  def groups
    object.groups.map {|g| g.name}.join(',')
  end
end
