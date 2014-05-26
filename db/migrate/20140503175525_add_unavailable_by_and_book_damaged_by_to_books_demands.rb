class AddUnavailableByAndBookDamagedByToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :unavailable_by, :integer
    add_column :books_demands, :book_damaged_by, :integer
  end
end
