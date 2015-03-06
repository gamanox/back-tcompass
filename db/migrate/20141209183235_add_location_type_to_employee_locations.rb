class AddLocationTypeToEmployeeLocations < ActiveRecord::Migration
  def change
    add_column :employee_locations, :location_type, :integer,default: 0
  end
end
