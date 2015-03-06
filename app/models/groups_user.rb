class GroupsUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group_id, uniqueness: {scope: :user_id,
    message: "User is already in this group"}
end
