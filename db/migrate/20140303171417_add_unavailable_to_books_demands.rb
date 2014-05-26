class AddUnavailableToBooksDemands < ActiveRecord::Migration
  def change
    add_column :books_demands, :unavailable, :boolean
  end
end
