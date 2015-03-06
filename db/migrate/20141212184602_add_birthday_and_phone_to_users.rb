class AddBirthdayAndPhoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birthday, :date
    add_column :users, :phone, :string
  end
end
