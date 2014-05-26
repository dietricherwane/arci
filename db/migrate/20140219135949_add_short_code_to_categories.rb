class AddShortCodeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :short_code, :string, limit: 3
  end
end
