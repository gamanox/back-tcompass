class ModifyBranches < ActiveRecord::Migration
  def change
    change_table :branches do |t|
      t.string :description
      t.string :phone
      t.string :email
    end
    rename_column :branches,:location,:latlng
  end
end
