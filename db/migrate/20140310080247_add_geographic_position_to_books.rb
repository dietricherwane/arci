class AddGeographicPositionToBooks < ActiveRecord::Migration
  def change
    add_column :books, :geographic_position, :string
  end
end
