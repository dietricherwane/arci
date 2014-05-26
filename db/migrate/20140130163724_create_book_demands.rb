class CreateBookDemands < ActiveRecord::Migration
  def change
    create_table :book_demands, :id => false do |t|
      t.integer :book_id
      t.integer :demand_id
      t.boolean :on_hold
      t.boolean :in_progress
      t.boolean :validated
      t.boolean :returned
      t.boolean :book_damaged

      t.timestamps
    end
    add_index :book_demands, [:book_id, :demand_id]
  end
end
