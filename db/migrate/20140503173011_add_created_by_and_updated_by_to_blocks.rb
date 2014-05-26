class AddCreatedByAndUpdatedByToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :created_by, :integer
    add_column :blocks, :update_by, :integer
  end
end
