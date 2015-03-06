class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :comment
      t.string :content
      t.integer :user_id

      t.timestamps
    end
  end
end
