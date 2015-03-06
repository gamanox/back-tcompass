class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.integer :client_id
      t.integer :employee_id
    end
  end
end
