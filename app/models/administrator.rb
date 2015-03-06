class Administrator < ActiveRecord::Base
  # or has one?
  belongs_to :employee
end
