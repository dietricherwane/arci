class AddCanValidateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_validate, :boolean
  end
end
