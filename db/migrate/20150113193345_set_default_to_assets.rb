class SetDefaultToAssets < ActiveRecord::Migration
  def change
    change_column :users,:qty_employees,:integer,default: 1
    change_column :users,:qty_branches,:integer,default: 1
    change_column :users,:qty_reports,:integer,default: 1
  end
end
