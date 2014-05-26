class AddCreatedByAndUpdatedByToUsers < ActiveRecord::Migration
  def change
    add_column :users, :created_by, :integer
    add_column :users, :update_by, :integer
  end
end
