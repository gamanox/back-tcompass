class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.belongs_to :user
      t.string :title
      t.string :description

      t.timestamps
    end

    create_table :pages do |t|
      t.belongs_to :report
      t.string :title

      t.timestamps
    end

    create_table :questions do |t|
      t.belongs_to :page
      t.integer :question_type
      t.string :title
      t.string :options,array: true

      t.timestamps
    end

    create_table :responses do |t|
      t.belongs_to :question
      t.belongs_to :user
      t.integer :question_type
      t.string :single_resp
      t.string :multiple_resp,array: true
      t.boolean :bool_resp

      t.timestamps
    end

    create_table :branch_responses do |t|
      t.belongs_to :branch
      t.belongs_to :response
    end

    create_table :group_reports do |t|
      t.belongs_to :group
      t.belongs_to :report
    end
  end
end
