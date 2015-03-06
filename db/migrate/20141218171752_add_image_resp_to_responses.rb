class AddImageRespToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :image_resp, :string
  end
end
