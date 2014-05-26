class AddArchiveBoxIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :archive_box_id, :integer
  end
end
