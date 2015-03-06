class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.belongs_to :user
      t.string :name
      t.string :address
      t.boolean :status, default: true
      t.string :location

      t.timestamps
    end
  end
end
