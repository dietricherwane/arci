class AddLeftToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :book_left, :boolean
  end
end
