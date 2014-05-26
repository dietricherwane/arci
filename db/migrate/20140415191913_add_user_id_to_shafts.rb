class AddUserIdToShafts < ActiveRecord::Migration
  def change
    add_column :shafts, :user_id, :integer
  end
end
