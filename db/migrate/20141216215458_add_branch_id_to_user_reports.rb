class AddBranchIdToUserReports < ActiveRecord::Migration
  def change
    add_column :user_reports,:branch_id,:integer
  end
end
