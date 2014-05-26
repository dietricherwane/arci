class AddCreatedByAndUpdatedByToArchiveBoxes < ActiveRecord::Migration
  def change
    add_column :archive_boxes, :created_by, :integer
    add_column :archive_boxes, :update_by, :integer
  end
end
