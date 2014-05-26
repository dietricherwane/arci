class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.integer :expires_in
      t.integer :notifies_in

      t.timestamps
    end
  end
end
