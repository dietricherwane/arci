class AddCreatedByAndUpdatedByToBooks < ActiveRecord::Migration
  def change
    add_column :books, :created_by, :integer
    add_column :books, :update_by, :integer
  end
end
