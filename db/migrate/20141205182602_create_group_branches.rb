class CreateGroupBranches < ActiveRecord::Migration
  def change
    create_table :group_branches do |t|
      t.belongs_to :group
      t.belongs_to :branch
    end
  end
end
