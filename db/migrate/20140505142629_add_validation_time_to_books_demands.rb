class AddValidationTimeToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :unavailable_by_at, :datetime
    add_column :books_demands, :validated_at, :datetime
    add_column :books_demands, :book_left_at, :datetime
    add_column :books_demands, :taken_by_at, :datetime
    add_column :books_demands, :returned_at, :datetime
    add_column :books_demands, :book_damaged_at, :datetime
    add_column :books_demands, :returned_by_at, :datetime
    add_column :books_demands, :book_damaged_by_at, :datetime
  end
end
