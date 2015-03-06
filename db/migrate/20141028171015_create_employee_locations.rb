class CreateEmployeeLocations < ActiveRecord::Migration
  def change
    create_table :employee_locations do |t|
      t.integer :user_id
      t.string :latlng
    end
  end
end
