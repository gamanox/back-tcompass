class EmployeeLocation < ActiveRecord::Base
  # location_type:
  # 0 - route
  # 1 - login
  # 2 - logout
  # 3 - report location
  belongs_to :user

  validates :latlng, presence: true
  validates :location_type,inclusion: {in: [0,1,2,3],
    message: "Not valid location type"}
end
