class Message < ActiveRecord::Base
  attr_accessor :read

  has_one :message_status, dependent: :destroy
  has_many :message_groups, dependent: :destroy
  has_many :comments, class_name: "Message", foreign_key: "comment_id",dependent: :destroy
  belongs_to :message,class_name: "Message", foreign_key: "comment_id"

  accepts_nested_attributes_for :message_groups

  belongs_to :user

  after_create :change_message_status
  after_create :create_status,if: "self.comment_id.nil?"

  validates :content,presence: true
  #validates :title,presence: true,if: Proc.new{|m| m.user.is_client?}

  def self.for(user,group_id = nil)
    messages =
      # If user is admin
      if !user.client_id.nil?
        # Get only main messages,not comments in a thread
        if group_id.nil?
          user.messages.where(comment_id: nil)
        else
          Message.joins(:message_groups).where("message_groups.group_id = ?",group_id)
        end
      else
        groups_ids = GroupsUser.select(:group_id).where(user_id: user.id)
        Message.joins(:message_groups).where("message_groups.group_id IN (?)",groups_ids)
      end
    messages.each {|m| m.is_read?(user.id)}
  end

  def assign_groups(groups_ids)
    groups_ids.each do |id|
      Group.find(id).message_groups.create(message_id: self.id)
    end
  end

  def is_read?(user_id)
    self.read = self.message_status.user_ids.include?(user_id)
  end

  def scope_count
    groups_ids = MessageGroup.select(:group_id).joins(:message).
      where("message_groups.message_id = ?",self.id)
    User.select(:id).joins(groups_users: :group).where("groups.id IN (?)",groups_ids).distinct.count
  end

  def is_comment?
    self.comment_id.nil? ? false : true
  end

  def has_owner?(user_id)
    if self.is_comment?
      self.message.user_id == user_id ? true : false
    else
      self.user_id == user_id ? true : false
    end
  end

  private
    def change_message_status
      if self.is_comment? && !self.has_owner?(self.user_id)
        self.message.update_column(:is_read,false)
      end
    end

    def create_status
      self.create_message_status
    end
end
