class User < ActiveRecord::Base
  include Tokenable
  has_secure_password

  attr_accessor :filtered_dates,:reports_count

  has_many :messages
  has_many :groups
  has_many :groups_users

  # Netser
  has_many :clients,   class_name: "User", foreign_key: "client_id"

  # Client
  has_many :employees, class_name: "User", foreign_key: "employee_id"
  has_many :branches
  has_many :administrators
  has_many :reports
  belongs_to :netser, class_name: "User", foreign_key: "client_id"

  # Employee
  has_many :employee_locations
  has_many :responses
  has_many :user_reports
  belongs_to :client, class_name: "User", foreign_key: "employee_id"

  # General validations
  validates :name,presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  # Client validations
  validates_with AssetsValidator,if: :is_client?
  validates :qty_reports,:qty_employees,:qty_branches,
            presence: true,numericality: {only_integer: true},
            if: :is_client?

  def self.login(params)
    user = User.where(email: params[:email],is_active: true).take!
    if user.authenticate(params[:password])
      user
    else
      raise ActiveRecord::RecordNotFound.new("User")
    end
  end

  # If client create employee, if superadmin create client
  def signup(params)
    if self.is_client?
      user = self.employees.create!(name: params[:name],last_name: params[:last_name],
      email: params[:email],password: params[:password],password_confirmation: params[:password_confirmation])
      GroupsUser.create!(user_id: user.id,group_id: params[:group_id])
      user
    else
      user = self.clients.create!(name: params[:name],email: params[:email],password: params[:password],
        password_confirmation: params[:password_confirmation])
    end
  end

  def filtered_employees(group_id)
    employees =
      Group.find(group_id).groups_users.map do |gu|
        User.find(gu.user_id)
      end
  end

  def assign_groups(groups_ids)
    user_id = self.id
    client = self.client
    self.groups_users.where("groups_users.user_id = ?",user_id).
      each {|relation| relation.destroy}
    groups_ids.each do |id|
      client.groups.find(id).groups_users.create(user_id: user_id)
    end
  end

  def in_groups
    Group.joins(:groups_users).where("groups_users.user_id = ?",self.id)
  end

  def stats
    today = DateTime.now
    {
      daily: self.user_reports.where("user_reports.created_at BETWEEN ? AND ?",
        today.beginning_of_day,today.end_of_day).count,
      weekly: self.user_reports.where("user_reports.created_at BETWEEN ? AND ?",
        today.beginning_of_week,today.end_of_week).count,
      total: self.user_reports.count
    }
  end

  def reports_done
    reports_answered = self.user_reports
    reports_answered.map do |a|
      rep = a.report
      attributes =
        {id: rep.id,name: rep.title,created_at: a.created_at,created_in: a.branch.name,
        user_id: self.id,branch_id: a.branch_id}
      BranchReport.new(attributes)
    end
  end

  #TODO: refactor to search within user's messages
  def read_message(message_id)
    message =
      if self.is_client?
        self.messages.find(message_id)
      elsif self.is_employee?
        self.client.messages.find(message_id)
      end
    if self.is_client?
      message.update_columns(is_read: true)
    else
      u_ids = message.message_status.user_ids.push(self.id)
      logger.info u_ids
      message.message_status.update_columns(user_ids: u_ids)
    end
  end

  def reports_date_filter(date_params,time_zone = TIMEZONE.cst)
    case date_params[:type].to_i
    when 1
      day_start = DateTime.parse("#{date_params[:start]}").beginning_of_day
      day_end = DateTime.parse("#{date_params[:start]}").end_of_day
    when 2
      day_start = DateTime.parse("#{date_params[:start]}").beginning_of_day
      day_end = DateTime.parse("#{date_params[:end]}").end_of_day
    end
    self.reports_count = self.user_reports.where("created_at BETWEEN ? AND ?",
      day_start + time_zone,day_end + time_zone).count
  end

  def toggle_is_active!
    if self.is_active
      self.update_column(:is_active,false)
    else
      self.update_column(:is_active,true)
    end
  end

  def is_client?
    !self.client_id.nil? ? true : false
  end

  def is_admin?
    if self.client_id.nil? && self.employee_id.nil?
      true
    else
      false
    end
  end

  def is_employee?
    !self.employee_id.nil? ? true : false
  end

  # TODO: there has to be a better way
  def clients
    if self.is_admin?
      User.where(client_id: self.id)
    else
      raise Unauthorized.new(self)
    end
  end
end
