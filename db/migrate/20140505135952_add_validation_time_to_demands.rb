class AddValidationTimeToDemands < ActiveRecord::Migration
  def change    
    add_column :demands, :validated_by_at, :datetime
    add_column :demands, :unavailable_by_at, :datetime
    add_column :demands, :validated_at, :datetime
    add_column :demands, :book_left_at, :datetime
    add_column :demands, :taken_by_at, :datetime
    add_column :demands, :returned_at, :datetime
    add_column :demands, :book_damaged_at, :datetime
    add_column :demands, :returned_by_at, :datetime
    add_column :demands, :book_damaged_by_at, :datetime
  end
end
