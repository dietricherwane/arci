class AddCreatedByAndUpdatedByToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :created_by, :integer
    add_column :departments, :update_by, :integer
  end
end
