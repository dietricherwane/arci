class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.string :name
      t.integer :shaft_id

      t.timestamps
    end
  end
end
