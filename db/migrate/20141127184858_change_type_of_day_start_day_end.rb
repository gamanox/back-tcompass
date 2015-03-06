class ChangeTypeOfDayStartDayEnd < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :day_start,:time
      t.change :day_end,:time
    end
  end
end
