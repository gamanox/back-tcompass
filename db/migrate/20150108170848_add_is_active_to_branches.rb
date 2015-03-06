class AddIsActiveToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :is_active, :boolean, default: true
  end
end
