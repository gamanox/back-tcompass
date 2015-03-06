class CreateUserReports < ActiveRecord::Migration
  def change
    create_table :user_reports do |t|
      t.belongs_to :user
      t.integer :report_id

      t.timestamps
    end
  end
end
