class GroupBranch < ActiveRecord::Base
  belongs_to :group
  belongs_to :branch

  validates :group_id, uniqueness: {scope: :branch_id,
    message: "Branch is already in this group"}
end
