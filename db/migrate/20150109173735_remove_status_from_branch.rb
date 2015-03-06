class RemoveStatusFromBranch < ActiveRecord::Migration
  def change
    remove_column :branches,:status
  end
end
