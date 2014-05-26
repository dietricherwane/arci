class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :phone_number

      t.timestamps
    end
  end
end
