class AddUnavailableToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :unavailable, :boolean
  end
end
