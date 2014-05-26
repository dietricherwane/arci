class AddUnavailableByAndBookDamagedByToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :unavailable_by, :integer
    add_column :demands, :book_damaged_by, :integer
  end
end
