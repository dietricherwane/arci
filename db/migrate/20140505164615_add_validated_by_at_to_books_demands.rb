class AddValidatedByAtToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :validated_by_at, :datetime
  end
end
