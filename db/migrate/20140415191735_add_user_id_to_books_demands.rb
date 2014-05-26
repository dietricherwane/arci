class AddUserIdToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :user_id, :integer
  end
end
