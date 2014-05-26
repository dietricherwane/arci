class AddCreatedByAndUpdatedByToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :created_by, :integer
    add_column :categories, :update_by, :integer
  end
end
