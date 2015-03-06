class AddSoftVerToUser < ActiveRecord::Migration
  def change
    add_column :users, :soft_ver, :string
  end
end
