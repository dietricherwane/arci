class AddShortcutToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :shortcut, :string
  end
end
