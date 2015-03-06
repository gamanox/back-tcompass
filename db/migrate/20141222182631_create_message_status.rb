class CreateMessageStatus < ActiveRecord::Migration
  def change
    create_table :message_statuses do |t|
      t.belongs_to :message

      t.integer :user_ids,array: true,default: []

      t.timestamps
    end
  end
end
