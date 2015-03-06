class Report < ActiveRecord::Base
  attr_accessor :place_name

  belongs_to :user
  has_many :group_reports,dependent: :destroy
  has_many :groups,through: :group_reports
  has_many :pages,dependent: :destroy

  accepts_nested_attributes_for :pages

  validates_with AssetsValidator

  def assign_groups(groups_ids)
    self.group_reports.
      where("group_reports.report_id = ?",self.id).each {|relation| relation.destroy}
    groups_ids.each do |id|
      self.user.groups.find(id).group_reports.create(report_id: self.id)
    end
  end

  def toggle_is_active!
    if self.is_active
      self.update_column(:is_active,false)
    else
      self.update_column(:is_active,true)
    end
  end
end
