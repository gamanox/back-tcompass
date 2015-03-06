class Group < ActiveRecord::Base
  belongs_to :user
  has_many :groups_users
  has_many :users,through: :groups_users
  has_many :message_groups
  has_many :messages,through: :message_groups
  has_many :group_reports
  has_many :reports,through: :group_reports
  has_many :group_branches
  has_many :branches,through: :group_branches

  validates :name,presence: true
end
