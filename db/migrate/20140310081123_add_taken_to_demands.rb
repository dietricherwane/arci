class AddTakenToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :taken, :boolean
  end
end
