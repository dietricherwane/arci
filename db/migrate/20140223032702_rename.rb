class Rename < ActiveRecord::Migration
  def change
    rename_table :book_demands, :books_demands
  end
end
