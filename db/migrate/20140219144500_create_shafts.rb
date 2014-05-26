class CreateShafts < ActiveRecord::Migration
  def change
    create_table :shafts do |t|
      t.string :name

      t.timestamps
    end
  end
end
