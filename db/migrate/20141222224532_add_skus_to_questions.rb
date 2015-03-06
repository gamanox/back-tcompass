class AddSkusToQuestions < ActiveRecord::Migration
  def change
    add_column :questions,:skus,:string,array: true
  end
end
