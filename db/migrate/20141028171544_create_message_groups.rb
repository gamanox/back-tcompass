class CreateMessageGroups < ActiveRecord::Migration
  def change
    create_table :message_groups do |t|
      t.integer :group_id
      t.integer :message_id
    end
  end
end
