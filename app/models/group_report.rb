class GroupReport < ActiveRecord::Base
  belongs_to :group
  belongs_to :report
  belongs_to :branch

  validates :group_id, uniqueness: {scope: :report_id,
    message: "Report is already in this group"}
end
