class AddValidatedByAndTakenByAndReturnedByToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :validated_by, :integer
    add_column :books_demands, :taken_by, :integer
    add_column :books_demands, :returned_by, :integer
  end
end
