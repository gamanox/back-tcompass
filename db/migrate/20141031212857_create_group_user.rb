class CreateGroupUser < ActiveRecord::Migration
  def change
    create_table :group_users do |t|
      t.belongs_to :user
      t.belongs_to :group
    end
  end
end
