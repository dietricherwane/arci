class AddTakenToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :taken, :boolean
  end
end
