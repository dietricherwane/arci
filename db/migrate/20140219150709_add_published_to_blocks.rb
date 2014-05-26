class AddPublishedToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :published, :boolean
  end
end
