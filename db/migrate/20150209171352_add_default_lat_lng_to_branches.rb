class AddDefaultLatLngToBranches < ActiveRecord::Migration
  def change
    change_column :branches,:latlng,:string,default: "37.769421, 122.48612"
  end
end
