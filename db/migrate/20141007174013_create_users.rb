class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :client
      t.references :employee
      t.string :name
      t.string :last_name
      t.string :address
      t.string :location
      t.integer :qty_reports
      t.integer :qty_employees
      t.datetime :day_start
      t.datetime :day_end
      t.boolean :state, default: true

      t.timestamps
    end
  end
end
