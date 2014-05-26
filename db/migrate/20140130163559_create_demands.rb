class CreateDemands < ActiveRecord::Migration
  def change
    create_table :demands do |t|
      t.integer :user_id
      t.datetime :expires_on
      t.boolean :on_hold
      t.boolean :in_progress
      t.boolean :validated
      t.boolean :returned
      t.boolean :book_damaged
      t.boolean :troubles_in

      t.timestamps
    end
  end
end
