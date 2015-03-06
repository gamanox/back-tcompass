class AddTimeStampsToEmployeeLocations < ActiveRecord::Migration
  def change
    change_table :employee_locations do |t|
      t.timestamps
    end
  end
end
