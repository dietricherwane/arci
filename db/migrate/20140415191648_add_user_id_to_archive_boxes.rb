class AddUserIdToArchiveBoxes < ActiveRecord::Migration
  def change
    add_column :archive_boxes, :user_id, :integer
  end
end
