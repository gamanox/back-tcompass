class AddQtyBranchesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :qty_branches, :integer
  end
end
