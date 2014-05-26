class AddLeftToDemands < ActiveRecord::Migration
  def change
    add_column :demands, :book_left, :boolean
  end
end
