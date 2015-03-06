class Branch < ActiveRecord::Base
  include UsersHelper

  belongs_to :user
  has_many :branch_responses
  has_many :responses,through: :branch_responses
  has_many :group_branches
  has_many :group_reports
  has_many :user_reports

  validates_with AssetsValidator

  def assign_groups(groups_ids)
    self.group_branches.where("group_branches.branch_id = ?",self.id).
      each {|relation| relation.destroy}
    groups_ids.each do |id|
      self.user.groups.find(id).group_branches.create(branch_id: self.id)
    end
  end

  def groups
    Group.joins(:group_branches).where("group_branches.branch_id = ?",self.id)
  end

  def reports
    resp = UserReport.where("user_reports.branch_id = ?",self.id)
    resp.map do |res|
      report = res.report
      user = res.user
      attributes =
        {id: report.id,name: report.title,created_at: res.created_at,
          created_by: full_name(user.name,user.last_name),user_id: user.id,
          branch_id: self.id}
      BranchReport.new(attributes)
    end
  end

  def stats
    today = DateTime.now
    {
      daily: self.user_reports.where("user_reports.created_at BETWEEN ? AND ?
      AND user_reports.branch_id = ?",
      today.beginning_of_day,today.end_of_day,self.id).count,
      weekly: self.user_reports.where("user_reports.created_at BETWEEN ? AND ?
      AND user_reports.branch_id = ?",
      today.beginning_of_week,today.end_of_week,self.id).count,
      total: self.user_reports.where("user_reports.branch_id = ?",self.id).count
    }
  end

  def toggle_is_active!
    if self.is_active
      self.update!(is_active:false)
    else
      self.update!(is_active:true)
    end
  end
end
