class AddUserIdToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :user_id, :integer
  end
end
