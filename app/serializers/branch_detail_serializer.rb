class BranchDetailSerializer < ActiveModel::Serializer
  attributes :id,:name,:description,:phone,:email,:latlng,:address,:stats,
    :is_active
  has_many :groups,serializer: Embedded::GroupSerializer
  has_many :reports,serializer: Embedded::ReportSerializer

  def groups
    object.groups
  end

  def reports
    object.reports
  end

  def stats
    object.stats
  end
end
