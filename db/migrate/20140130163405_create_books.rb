class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :code
      t.string :title
      t.text :description
      t.integer :total_quantity
      t.integer :quantity_in_stock
      t.integer :category_id
      t.boolean :published

      t.timestamps
    end
  end
end
