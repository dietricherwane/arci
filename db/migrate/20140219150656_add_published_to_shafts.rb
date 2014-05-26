class AddPublishedToShafts < ActiveRecord::Migration
  def change
    add_column :shafts, :published, :boolean
  end
end
