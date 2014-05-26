class AddPublishedToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :published, :boolean
  end
end
