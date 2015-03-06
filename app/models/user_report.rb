class UserReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :report
  belongs_to :branch
end
