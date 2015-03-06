class AddIsActiveToReports < ActiveRecord::Migration
  def change
    add_column :reports, :is_active, :boolean,default: true
  end
end
