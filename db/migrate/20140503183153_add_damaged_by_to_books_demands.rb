class AddDamagedByToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :damaged_by, :integer
  end
end
