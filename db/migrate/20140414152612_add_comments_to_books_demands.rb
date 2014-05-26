class AddCommentsToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :comments, :text
  end
end
