class AddCreatedByAndUpdatedByToShafts < ActiveRecord::Migration
  def change
    add_column :shafts, :created_by, :integer
    add_column :shafts, :update_by, :integer
  end
end
