class AddDamagedByToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :damaged_by, :integer
  end
end
